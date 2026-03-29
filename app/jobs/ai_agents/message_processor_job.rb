class AiAgents::MessageProcessorJob < ApplicationJob
  queue_as :default

  def perform(message:, ai_agent:)
    return unless message.incoming?
    return unless ai_agent.is_active?

    AiAgents::MessageProcessorService.new(
      message: message,
      ai_agent: ai_agent
    ).perform
  rescue StandardError => e
    ChatwootExceptionTracker.new(e, account: message.account).capture_exception
  end
end
