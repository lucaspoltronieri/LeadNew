class AiAgentListener < BaseListener
  def message_created(event)
    message, account = extract_message_and_account(event)
    return unless message.incoming?

    inbox = message.inbox
    ai_agents = inbox.ai_agents.where(is_active: true)

    ai_agents.each do |ai_agent|
      AiAgents::MessageProcessorJob.perform_later(message: message, ai_agent: ai_agent)
    end
  end
end
