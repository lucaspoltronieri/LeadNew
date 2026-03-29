require 'rails_helper'

RSpec.describe Whatsapp::Providers::EvolutionService do
  let(:account) { create(:account) }
  let(:whatsapp_channel) { create(:channel_whatsapp, account: account, provider: 'evolution', provider_config: { 'api_key' => 'secret', 'instance_name' => 'leadnew_instance' }) }
  let(:service) { described_class.new(whatsapp_channel: whatsapp_channel) }
  let(:base_url) { ENV.fetch('EVOLUTION_SERVER_URL', 'http://localhost:8080') }

  before do
    allow(Rails.logger).to receive(:error)
  end

  describe '#setup_webhooks' do
    it 'creates an instance and sets webhook in Evolution API' do
      # 1. Mock create instance
      stub_request(:post, "#{base_url}/instance/create")
        .to_return(status: 201, body: { instance: { instanceName: 'leadnew_instance', status: 'created' } }.to_json)

      # 2. Mock set webhook
      stub_request(:post, "#{base_url}/webhook/set/leadnew_instance")
        .to_return(status: 200, body: { status: 'success' }.to_json)

      expect(service.setup_webhooks).to be_truthy
    end
  end

  describe '#send_message' do
    let(:message) { create(:message, content: 'Hello Evolution') }

    it 'sends message to evolution api' do
      stub_request(:post, "#{base_url}/message/sendText/leadnew_instance")
        .with(body: hash_including(number: anything, text: 'Hello Evolution'))
        .to_return(status: 201, body: { key: { id: 'ext_123' } }.to_json)

      response = service.send_message(message: message)
      expect(response).to be_present
    end
  end

  describe '#validate_provider_config?' do
    it 'returns true if instance exists and api key is valid' do
      stub_request(:get, "#{base_url}/instance/fetchInstances")
        .to_return(status: 200, body: [{ instanceName: 'leadnew_instance' }].to_json)
      
      expect(service.validate_provider_config?).to be_truthy
    end
  end
end
