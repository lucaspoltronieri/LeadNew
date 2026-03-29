require 'rails_helper'

RSpec.describe AiAgents::MessageProcessorService do
  let(:account) { create(:account) }
  let(:inbox) { create(:inbox, account: account) }
  let(:conversation) { create(:conversation, account: account, inbox: inbox) }
  let(:ai_agent) { create(:ai_agent, account: account, inbox: inbox, is_active: true, system_prompt: 'You are a helpful assistant.') }
  let!(:incoming_message) { create(:message, account: account, inbox: inbox, conversation: conversation, message_type: :incoming, content: 'Hello there!') }
  let!(:token_ledger) { create(:token_ledger, account: account, tokens_purchased: 1000, tokens_used: 0) }

  let(:service) { described_class.new(message: incoming_message, ai_agent: ai_agent) }

  describe '#perform' do
    context 'when conversation is valid for processing' do
      let(:mock_openai_client) { instance_double(OpenAI::Client) }
      let(:mock_response) do
        {
          'usage' => { 'total_tokens' => 50 },
          'choices' => [
            { 'message' => { 'content' => 'Hello! How can I help you today?' } }
          ]
        }
      end

      before do
        allow(OpenAI::Client).to receive(:new).and_return(mock_openai_client)
      end

      it 'calls OpenAI and creates a reply message' do
        expect(mock_openai_client).to receive(:chat).with(
          hash_including(
            parameters: hash_including(
              model: 'gpt-3.5-turbo',
              messages: [
                { role: 'system', content: 'You are a helpful assistant.' },
                { role: 'user', content: 'Hello there!' }
              ]
            )
          )
        ).and_return(mock_response)

        expect do
          service.perform
        end.to change(conversation.messages, :count).by(1)

        last_message = conversation.messages.last
        expect(last_message.content).to eq('Hello! How can I help you today?')
        expect(last_message.sender).to eq(ai_agent)
        expect(last_message.message_type).to eq('outgoing')

        expect(token_ledger.reload.tokens_used).to eq(50)
        expect(token_ledger.reload.balance).to eq(950)
      end

      it 'returns nil if openai fails' do
        expect(mock_openai_client).to receive(:chat).and_raise(Faraday::Error.new("Connection failed"))

        expect do
          service.perform
        end.not_to change(conversation.messages, :count)
      end
    end

    context 'when conversation is resolved' do
      before do
        conversation.update!(status: :resolved)
      end

      it 'does not process the message' do
        expect(OpenAI::Client).not_to receive(:new)
        
        expect do
          service.perform
        end.not_to change(conversation.messages, :count)
      end
    end

    context 'when account has no tokens' do
      before do
        token_ledger.update!(tokens_purchased: 0, tokens_used: 0)
      end

      it 'returns early and does not call OpenAI' do
        expect(OpenAI::Client).not_to receive(:new)
        
        expect do
          service.perform
        end.not_to change(conversation.messages, :count)
      end
    end
  end
end
