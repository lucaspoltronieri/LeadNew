require 'rails_helper'

RSpec.describe 'Api::V1::Accounts::CrmPipelines', type: :request do
  let(:account) { create(:account) }
  let(:admin) { create(:user, account: account, role: :administrator) }
  let!(:pipeline) { create(:crm_pipeline, account: account, name: 'Sales') }

  describe 'GET /api/v1/accounts/:account_id/crm_pipelines' do
    it 'returns all pipelines' do
      get "/api/v1/accounts/#{account.id}/crm_pipelines",
          headers: admin.create_new_auth_token,
          as: :json

      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json['payload'].length).to eq(1)
      expect(json['payload'][0]['name']).to eq('Sales')
    end
  end

  describe 'POST /api/v1/accounts/:account_id/crm_pipelines' do
    it 'creates a new pipeline' do
      post "/api/v1/accounts/#{account.id}/crm_pipelines",
           headers: admin.create_new_auth_token,
           params: { crm_pipeline: { name: 'Support' } },
           as: :json

      expect(response).to have_http_status(:success)
      expect(account.crm_pipelines.count).to eq(2)
    end
  end
end
