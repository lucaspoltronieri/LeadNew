require 'rails_helper'

RSpec.describe Api::V1::Webhooks::AsaasController, type: :controller do
  let(:account) { create(:account) }
  # Mocking the model since factory might not exist yet
  let!(:account_billing) { AccountBilling.create(account: account, asaas_customer_id: 'cus_000005118742', subscription_status: 'pending') }

  let(:payment_confirmed_payload) do
    {
      "event" => "PAYMENT_CONFIRMED",
      "payment" => {
        "customer" => "cus_000005118742",
        "value" => 100.00
      }
    }
  end

  let(:payment_overdue_payload) do
    {
      "event" => "PAYMENT_OVERDUE",
      "payment" => {
        "customer" => "cus_000005118742",
        "value" => 100.00
      }
    }
  end

  describe 'POST #create' do
    context 'when receiving PAYMENT_CONFIRMED' do
      let!(:token_ledger) { create(:token_ledger, account: account, tokens_purchased: 0) }

      it 'updates account billing status to active and credits tokens' do
        # 100.00 BRL = 10,000 tokens (100 * 100)
        expect {
          post :create, params: payment_confirmed_payload, as: :json
        }.to change { token_ledger.reload.tokens_purchased }.by(10000)
        
        expect(response).to have_http_status(:ok)
        expect(account_billing.reload.subscription_status).to eq('active')
        expect(token_ledger.reload.balance).to eq(10000)
      end
    end

    context 'when receiving PAYMENT_OVERDUE' do
      it 'updates account billing status to suspended' do
        post :create, params: payment_overdue_payload, as: :json
        
        expect(response).to have_http_status(:ok)
        expect(account_billing.reload.subscription_status).to eq('suspended')
      end
    end

    context 'when receiving unknown customer' do
      it 'responds with ok but logs the not found warning' do
        post :create, params: { event: 'PAYMENT_CONFIRMED', payment: { customer: 'unknown' } }, as: :json
        
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
