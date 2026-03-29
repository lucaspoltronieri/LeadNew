require 'rails_helper'

RSpec.describe AiAgentListener do
  let(:listener) { described_class.instance }
  let(:account) { create(:account) }
  let(:inbox) { create(:inbox, account: account) }
  let(:conversation) { create(:conversation, account: account, inbox: inbox) }
  let!(:ai_agent) { create(:ai_agent, account: account, inbox: inbox, is_active: true) }

  describe '#message_created' do
    context 'when the message is incoming and inbox has an active AI agent' do
      let(:message) { create(:message, account: account, inbox: inbox, conversation: conversation, message_type: :incoming) }
      let(:event) { double(data: { message: message }) }

      it 'enqueues the MessageProcessorJob' do
        expect(AiAgents::MessageProcessorJob).to receive(:perform_later)
          .with(message: message, ai_agent: ai_agent)

        listener.message_created(event)
      end
    end

    context 'when the message is not incoming' do
      let(:message) { create(:message, account: account, inbox: inbox, conversation: conversation, message_type: :outgoing) }
      let(:event) { double(data: { message: message }) }

      it 'does not enqueue the MessageProcessorJob' do
        expect(AiAgents::MessageProcessorJob).not_to receive(:perform_later)

        listener.message_created(event)
      end
    end

    context 'when inbox does not have an active AI agent' do
      before do
        ai_agent.update!(is_active: false)
      end

      let(:message) { create(:message, account: account, inbox: inbox, conversation: conversation, message_type: :incoming) }
      let(:event) { double(data: { message: message }) }

      it 'does not enqueue the MessageProcessorJob' do
        expect(AiAgents::MessageProcessorJob).not_to receive(:perform_later)

        listener.message_created(event)
      end
    end
  end
end
