require 'rails_helper'

RSpec.describe AiAgents::MessageProcessorJob, type: :job do
  subject(:job) { described_class.perform_later(message: message, ai_agent: ai_agent) }

  let(:account) { create(:account) }
  let(:inbox) { create(:inbox, account: account) }
  let(:conversation) { create(:conversation, account: account, inbox: inbox) }
  let(:ai_agent) { create(:ai_agent, account: account, inbox: inbox, is_active: true) }

  context 'when message is incoming and ai agent is active' do
    let(:message) { create(:message, account: account, inbox: inbox, conversation: conversation, message_type: :incoming) }
    
    it 'calls the MessageProcessorService' do
      service_instance = instance_double(AiAgents::MessageProcessorService)
      expect(AiAgents::MessageProcessorService).to receive(:new).with(message: message, ai_agent: ai_agent).and_return(service_instance)
      expect(service_instance).to receive(:perform)

      described_class.perform_now(message: message, ai_agent: ai_agent)
    end
  end

  context 'when ai agent is disabled' do
    let(:message) { create(:message, account: account, inbox: inbox, conversation: conversation, message_type: :incoming) }
    
    before do
      ai_agent.update!(is_active: false)
    end
    
    it 'does not call the MessageProcessorService' do
      expect(AiAgents::MessageProcessorService).not_to receive(:new)
      described_class.perform_now(message: message, ai_agent: ai_agent)
    end
  end
end
