class AiAgents::MessageProcessorService
  def initialize(message:, ai_agent:)
    @message = message
    @ai_agent = ai_agent
    @conversation = message.conversation
    @account = message.account
    @token_ledger = @account.token_ledger || @account.create_token_ledger
  end

  def perform
    return unless should_process_message?

    build_and_send_response
  end

  private

  def should_process_message?
    # Ensure no humans have handled this recently, it's not a muted conversation, etc
    return false if @conversation.resolved? || @conversation.muted?
    
    # Financial validation
    return false if @token_ledger.balance <= 0

    true
  end

  def build_and_send_response
    messages = conversation_history
    ai_response = ask_openai(messages)
    
    return if ai_response.blank?

    # Extracts content and usage
    content = ai_response.dig('choices', 0, 'message', 'content')
    usage_total = ai_response.dig('usage', 'total_tokens') || 0

    if content.blank?
      Rails.logger.warn "[AiAgents] OpenAI returned empty content for Message #{@message.id}"
      return
    end

    @token_ledger.debit!(usage_total)
    create_message(content)
  end

  def conversation_history
    # Get last 15 messages for context
    messages = @conversation.messages.where.not(message_type: :activity)
                            .order(created_at: :desc)
                            .limit(15).reverse

    formatted_messages = messages.map do |msg|
      role = msg.incoming? ? 'user' : 'assistant'
      { role: role, content: msg.content_for_llm || '[Attachment]' }
    end

    # Prepend the system prompt
    system_message = { role: 'system', content: @ai_agent.system_prompt || 'Você é um assistente útil do LeadNew.' }
    [system_message] + formatted_messages
  end

  def ask_openai(messages)
    # Priority: Database Config (Super Admin UI) -> Environment Variable (ENV)
    openai_key = GlobalConfig.get('OPENAI_API_KEY')['OPENAI_API_KEY'].presence || ENV.fetch('OPENAI_API_KEY', nil)
    
    if openai_key.blank?
      Rails.logger.error '[AiAgents] OPENAI_API_KEY is missing'
      return nil
    end

    client = ::OpenAI::Client.new(access_token: openai_key)
    
    response = client.chat(
      parameters: {
        model: 'gpt-3.5-turbo',
        messages: messages,
        temperature: 0.7
      }
    )

    if response.key?('error')
      Rails.logger.error "[AiAgents] OpenAI API explicit error: #{response['error']}"
      return nil
    end

    response
  rescue StandardError => e
    Rails.logger.error "[AiAgents] OpenAI API Exception for AI Agent #{@ai_agent.id}: #{e.message}"
    nil
  end

  def create_message(content)
    # Use ActionController::Parameters to ensure MessageBuilder doesn't return early
    params = ActionController::Parameters.new({
      content: content,
      private: false,
      message_type: 'outgoing'
    })

    # AiAgent itself acts as the sender polymorphic
    message_builder = Messages::MessageBuilder.new(@ai_agent, @conversation, params)
    message_builder.perform
  end
end
