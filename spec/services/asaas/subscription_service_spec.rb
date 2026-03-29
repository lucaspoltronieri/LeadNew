require 'rails_helper'

RSpec.describe Asaas::SubscriptionService, type: :service do
  let(:api_key) { 'dummy_api_key' }
  let(:base_url) { 'https://sandbox.asaas.com/api/v3' }
  
  before do
    allow(ENV).to receive(:fetch).with('ASAAS_API_KEY', '').and_return(api_key)
    allow(ENV).to receive(:fetch).with('ASAAS_API_URL', 'https://sandbox.asaas.com/api/v3').and_return(base_url)
    allow(Rails.logger).to receive(:error)
  end

  describe '#create_customer' do
    context 'when API returns success' do
      before do
        stub_request(:post, "#{base_url}/customers")
          .with(
            headers: { 'access_token' => api_key, 'Content-Type' => 'application/json' }
          )
          .to_return(status: 200, body: { id: 'cus_123456', object: 'customer' }.to_json)
      end

      it 'returns the created customer data' do
        response = described_class.new.create_customer(name: 'LeadNew Test', email: 'financeiro@leadnew.com')
        expect(response['id']).to eq('cus_123456')
      end
    end

    context 'when API returns an error' do
      before do
        stub_request(:post, "#{base_url}/customers")
          .to_return(status: 400, body: { errors: [{ description: 'Invalid email' }] }.to_json)
      end

      it 'logs the error and returns nil' do
        response = described_class.new.create_customer(name: 'LeadNew Test', email: 'invalid')
        expect(Rails.logger).to have_received(:error).with(/Asaas API Error \(create_customer\)/)
        expect(response).to be_nil
      end
    end
  end

  describe '#create_subscription' do
    let(:customer_id) { 'cus_123456' }
    let(:plan_value) { 199.90 }

    context 'when API returns success' do
      before do
        stub_request(:post, "#{base_url}/subscriptions")
          .to_return(status: 200, body: { id: 'sub_78910', status: 'ACTIVE' }.to_json)
      end

      it 'returns the created subscription data' do
        response = described_class.new.create_subscription(
          customer_id: customer_id,
          value: plan_value,
          billing_type: 'CREDIT_CARD',
          cycle: 'MONTHLY'
        )
        expect(response['id']).to eq('sub_78910')
      end
    end

    context 'when API raises an exception' do
      before do
        stub_request(:post, "#{base_url}/subscriptions").to_timeout
      end

      it 'rescues, logs the exception and returns nil' do
        response = described_class.new.create_subscription(
          customer_id: customer_id,
          value: plan_value,
          billing_type: 'CREDIT_CARD',
          cycle: 'MONTHLY'
        )
        expect(Rails.logger).to have_received(:error).with(/Asaas API Exception \(create_subscription\)/)
        expect(response).to be_nil
      end
    end
  end
end
