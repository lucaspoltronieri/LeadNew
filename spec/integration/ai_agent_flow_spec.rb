require 'rails_helper'

RSpec.describe 'AI Agent Integration Flow', type: :request do
  let(:account) { create(:account) }
  let(:admin) { create(:user, account: account, role: :administrator) }
  let(:inbox) { create(:inbox, account: account) }
  let(:contact) { create(:contact, account: account) }
  let(:contact_inbox) { create(:contact_inbox, contact: contact, inbox: inbox) }
  let(:conversation) { create(:conversation, account: account, inbox: inbox, contact: contact, contact_inbox: contact_inbox) }
  let!(:ai_agent) do
    create(:ai_agent, 
      account: account, 
      inbox: inbox, 
      is_active: true, 
      system_prompt: 'You are a LeadNew helper.')
  end
  let!(:token_ledger) { create(:token_ledger, account: account, tokens_purchased: 1000) }

  let(:openai_response) do
    {
      'choices' => [{ 'message' => { 'content' => 'AI Response content' } }],
      'usage' => { 'total_tokens' => 25 }
    }
  end

  before do
    allow(OpenAI::Client).to receive(:new).and_return(double(chat: openai_response))
  end

  it 'processes an incoming message and generates an AI reply' do
    # 1. Simular recebimento de mensagem via API (ou criação direta)
    expect {
      create(:message, 
        account: account, 
        inbox: inbox, 
        conversation: conversation, 
        sender: contact, 
        message_type: :incoming, 
        content: 'Hello AI')
    }.to have_enqueued_job(AiAgents::MessageProcessorJob)

    # 2. Executar o Job manualmente no contexto do teste (ou usar perform_enqueued_jobs)
    # Aqui vamos rodar o serviço diretamente para garantir a verificação do estado
    incoming_message = conversation.messages.last
    AiAgents::MessageProcessorService.new(message: incoming_message, ai_agent: ai_agent).perform

    # 3. Verificar se a resposta foi criada
    reply = conversation.messages.reload.last
    expect(reply.content).to eq('AI Response content')
    expect(reply.sender).to eq(ai_agent)
    expect(reply.message_type).to eq('outgoing')

    # 4. Verificar o débito de tokens
    expect(token_ledger.reload.tokens_used).to eq(25)
    expect(token_ledger.reload.balance).to eq(975)
  end

  it 'does not reply if token balance is zero' do
    token_ledger.update!(tokens_purchased: 5, tokens_used: 5) # Balance 0
    
    incoming_message = create(:message, account: account, inbox: inbox, conversation: conversation, content: 'Low funds')
    
    expect {
      AiAgents::MessageProcessorService.new(message: incoming_message, ai_agent: ai_agent).perform
    }.not_to change(conversation.messages, :count)
  end
end
