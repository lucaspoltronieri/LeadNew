require 'rails_helper'

RSpec.describe CrmDeal, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:account) }
    it { is_expected.to belong_to(:crm_stage) }
    it { is_expected.to belong_to(:contact) }
    it { is_expected.to belong_to(:conversation).optional }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:crm_stage_id) }
    it { is_expected.to validate_presence_of(:contact_id) }
  end

  describe 'status' do
    it 'defaults to open' do
      deal = CrmDeal.new
      expect(deal.status).to eq('open')
    end
  end
end
