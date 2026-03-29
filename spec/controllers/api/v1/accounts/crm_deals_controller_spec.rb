require 'rails_helper'

RSpec.describe 'Api::V1::Accounts::CrmDeals', type: :request do
  let(:account) { create(:account) }
  let(:admin) { create(:user, account: account, role: :administrator) }
  let(:pipeline) { create(:crm_pipeline, account: account) }
  let(:stage) { create(:crm_stage, crm_pipeline: pipeline) }
  let!(:deal) { create(:crm_deal, account: account, crm_stage: stage, title: 'Old Deal') }

  describe 'GET /api/v1/accounts/:account_id/crm_deals' do
    it 'returns deals for a pipeline' do
      get "/api/v1/accounts/#{account.id}/crm_deals",
          params: { crm_pipeline_id: pipeline.id },
          headers: admin.create_new_auth_token,
          as: :json

      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json['payload'].length).to eq(1)
    end
  end

  describe 'POST /api/v1/accounts/:account_id/crm_deals' do
    it 'creates a new deal' do
      post "/api/v1/accounts/#{account.id}/crm_deals",
           headers: admin.create_new_auth_token,
           params: { crm_deal: { title: 'New Deal', crm_stage_id: stage.id } },
           as: :json

      expect(response).to have_http_status(:success)
      expect(account.crm_deals.count).to eq(2)
    end
  end

  describe 'PATCH /api/v1/accounts/:account_id/crm_deals/:id/move' do
    let(:new_stage) { create(:crm_stage, crm_pipeline: pipeline, name: 'Negotiation') }

    it 'moves a deal to a new stage' do
      patch "/api/v1/accounts/#{account.id}/crm_deals/#{deal.id}/move",
            headers: admin.create_new_auth_token,
            params: { crm_stage_id: new_stage.id },
            as: :json

      expect(response).to have_http_status(:success)
      expect(deal.reload.crm_stage_id).to eq(new_stage.id)
    end
  end
end
