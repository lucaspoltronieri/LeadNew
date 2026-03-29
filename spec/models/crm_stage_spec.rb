require 'rails_helper'

RSpec.describe CrmStage, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:crm_pipeline) }
    it { is_expected.to have_many(:crm_deals).dependent(:nullify) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:crm_pipeline_id) }
  end
end
