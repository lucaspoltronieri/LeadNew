require 'rails_helper'

RSpec.describe CrmPipeline, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:account) }
    it { is_expected.to have_many(:crm_stages).dependent(:destroy) }
    it { is_expected.to have_many(:crm_deals).through(:crm_stages) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
  end
end
