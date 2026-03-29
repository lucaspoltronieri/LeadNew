require 'rails_helper'

RSpec.describe 'Api::V1::Accounts::AiAgents', type: :request do
  let(:account) { create(:account) }
  let(:inbox) { create(:inbox, account: account) }
  let(:administrator) { create(:user, account: account, role: :administrator) }
  let!(:ai_agent1) { create(:ai_agent, account: account, inbox: inbox, name: 'Bot 1') }
  let!(:ai_agent2) { create(:ai_agent, account: account, inbox: inbox, name: 'Bot 2') }

  describe 'GET /api/v1/accounts/:account_id/ai_agents' do
    context 'when it is an unauthenticated user' do
      it 'returns unauthorized' do
        get "/api/v1/accounts/#{account.id}/ai_agents"
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when it is an authenticated administrator' do
      it 'returns all ai agents for the account' do
        get "/api/v1/accounts/#{account.id}/ai_agents",
            headers: administrator.create_new_auth_token,
            as: :json

        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body)
        expect(json_response['payload'].length).to eq(2)
        expect(json_response['payload'].pluck('id')).to include(ai_agent1.id, ai_agent2.id)
      end
    end
  end

  describe 'POST /api/v1/accounts/:account_id/ai_agents' do
    let(:valid_attributes) do
      {
        name: 'Super Bot',
        system_prompt: 'You are an AI assistant.',
        inbox_id: inbox.id,
        is_active: true
      }
    end

    context 'when it is an authenticated administrator' do
      it 'creates a new ai agent' do
        expect do
          post "/api/v1/accounts/#{account.id}/ai_agents",
               headers: administrator.create_new_auth_token,
               params: { ai_agent: valid_attributes },
               as: :json
        end.to change(AiAgent, :count).by(1)

        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body)
        expect(json_response['payload']['name']).to eq('Super Bot')
      end

      it 'returns unprocessable entity for invalid attributes' do
        post "/api/v1/accounts/#{account.id}/ai_agents",
             headers: administrator.create_new_auth_token,
             params: { ai_agent: { name: '', inbox_id: nil } },
             as: :json

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'PATCH /api/v1/accounts/:account_id/ai_agents/:id' do
    context 'when it is an authenticated administrator' do
      it 'updates the ai agent' do
        patch "/api/v1/accounts/#{account.id}/ai_agents/#{ai_agent1.id}",
              headers: administrator.create_new_auth_token,
              params: { ai_agent: { name: 'Updated Bot' } },
              as: :json

        expect(response).to have_http_status(:success)
        expect(ai_agent1.reload.name).to eq('Updated Bot')
      end
    end
  end

  describe 'DELETE /api/v1/accounts/:account_id/ai_agents/:id' do
    context 'when it is an authenticated administrator' do
      it 'deletes the ai agent' do
        expect do
          delete "/api/v1/accounts/#{account.id}/ai_agents/#{ai_agent1.id}",
                 headers: administrator.create_new_auth_token,
                 as: :json
        end.to change(AiAgent, :count).by(-1)

        expect(response).to have_http_status(:success)
      end
    end
  end
end
