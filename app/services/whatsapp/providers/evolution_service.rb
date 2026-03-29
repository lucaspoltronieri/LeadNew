class Whatsapp::Providers::EvolutionService < Whatsapp::Providers::BaseService
  def send_message(phone_number, message)
    @message = message
    response = HTTParty.post(
      "#{api_base_path}/message/sendText/#{instance_name}",
      headers: api_headers,
      body: {
        number: phone_number,
        options: { delay: 1200, presence: 'composing', linkPreview: false },
        text: message.outgoing_content
      }.to_json
    )

    process_response(response, message)
  end

  def send_template(_phone_number, _template_info, _message)
    # Evolution API basic text doesn't strictly enforce templates like official API
    # We can fallback to send_message or implement specific Evolution templates if needed
    send_message(_phone_number, _message)
  end

  def sync_templates
    # No templates sync needed for unofficial API usually
    whatsapp_channel.mark_message_templates_updated
  end

  def validate_provider_config?
    response = HTTParty.get("#{api_base_path}/instance/fetchInstances", headers: api_headers)
    return false unless response.success?

    instances = response.parsed_response
    instances.any? { |i| i['instanceName'] == instance_name }
  rescue StandardError => e
    Rails.logger.error "[EvolutionService] Validation failed: #{e.message}"
    false
  end

  def setup_webhooks
    # 1. Create instance
    create_instance_response = HTTParty.post(
      "#{api_base_path}/instance/create",
      headers: api_headers,
      body: {
        instanceName: instance_name,
        token: whatsapp_channel.provider_config['api_key'],
        qrcode: true
      }.to_json
    )

    return false unless create_instance_response.success? || create_instance_response.code == 403 # 403 usually means instance already exists

    # 2. Set Webhook
    webhook_url = "#{ENV.fetch('FRONTEND_URL', 'http://localhost:3000')}/api/v1/webhooks/evolution"
    HTTParty.post(
      "#{api_base_path}/webhook/set/#{instance_name}",
      headers: api_headers,
      body: {
        url: webhook_url,
        enabled: true,
        events: ['MESSAGES_UPSERT', 'MESSAGES_UPDATE', 'SEND_MESSAGE', 'CONNECTION_UPDATE']
      }.to_json
    ).success?
  end

  def process_response(response, message)
    if response.success?
      # Evolution API returns { key: { id: '...' } } for messages
      response.parsed_response.dig('key', 'id') || response.parsed_response.dig('message', 'key', 'id')
    else
      handle_error(response, message)
      nil
    end
  end

  def api_headers
    { 
      'apikey' => whatsapp_channel.provider_config['api_key'] || GlobalConfig.get('EVOLUTION_API_KEY')['EVOLUTION_API_KEY'].presence || ENV.fetch('EVOLUTION_API_KEY', 'leadnew_secret_key'),
      'Content-Type' => 'application/json' 
    }
  end

  private

  def api_base_path
    GlobalConfig.get('EVOLUTION_SERVER_URL')['EVOLUTION_SERVER_URL'].presence || ENV.fetch('EVOLUTION_SERVER_URL', 'http://localhost:8080')
  end

  def instance_name
    whatsapp_channel.provider_config['instance_name'] || "leadnew_#{whatsapp_channel.id}"
  end

  def error_message(response)
    response.parsed_response&.dig('message') || response.parsed_response&.dig('error') || 'Unknown error'
  end
end
