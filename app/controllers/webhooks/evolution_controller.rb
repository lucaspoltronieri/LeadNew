class Webhooks::EvolutionController < ActionController::API
  def process_payload
    instance_name = params[:instance]
    event = params[:event]
    
    # Evolution API sends messages in MESSAGES_UPSERT event
    if event == 'MESSAGES_UPSERT'
      process_message(params[:data])
    elsif event == 'CONNECTION_UPDATE'
      process_connection_update(params[:data])
    end

    head :ok
  rescue StandardError => e
    Rails.logger.error "[EvolutionWebhook] Error processing payload: #{e.message}"
    head :ok # Return OK to avoid retries from Evolution on transient errors
  end

  private

  def process_message(data)
    # 1. Identify Channel
    instance_name = params[:instance]
    channel = Channel::Whatsapp.where(provider: 'evolution')
                               .where("provider_config->>'instance_name' = ?", instance_name).first
    return if channel.blank?

    message_data = data['message']
    return if message_data.blank?
    
    # Avoid processing outgoing messages sent from LeadNew (loop prevention)
    return if data['key']['fromMe']

    # 2. Extract Info
    sender_phone = data['key']['remoteJid'].split('@').first
    content = message_data['conversation'] || message_data.dig('extendedTextMessage', 'text') || '[Midia não suportada]'
    
    # 3. Create Contact/Conversation/Message
    # Reuse Chatwoot's logic
    contact = contact_builder(channel, sender_phone)
    conversation = conversation_builder(channel, contact)
    
    create_message(channel, conversation, contact, content, data['key']['id'])
  end

  def contact_builder(channel, phone)
    # Chatwoot has built-in contact discovery by source_id
    contact_inbox = channel.inbox.contact_inboxes.find_by(source_id: phone)
    return contact_inbox.contact if contact_inbox.present?

    # Create new contact
    contact = channel.account.contacts.create!(
      name: "Whatsapp User #{phone}",
      phone_number: "+#{phone}"
    )
    
    channel.inbox.contact_inboxes.create!(
      contact: contact,
      inbox: channel.inbox,
      source_id: phone
    )
    
    contact
  end

  def conversation_builder(channel, contact)
    conversation = contact.conversations.where(inbox_id: channel.inbox_id, status: :open).last
    conversation ||= channel.account.conversations.create!(
      contact: contact,
      inbox: channel.inbox,
      contact_inbox: contact.contact_inboxes.find_by(inbox_id: channel.inbox_id),
      status: :open
    )
    conversation
  end

  def create_message(channel, conversation, contact, content, external_id)
    return if Message.find_by(source_id: external_id).present?

    message = conversation.messages.build(
      account_id: channel.account_id,
      inbox_id: channel.inbox_id,
      message_type: :incoming,
      content: content,
      source_id: external_id,
      sender: contact
    )
    message.save!
  end

  def process_connection_update(data)
    # Log connection status changes (open, connecting, close)
    Rails.logger.info "[EvolutionWebhook] Connection status for #{params[:instance]}: #{data['status']}"
  end
end
