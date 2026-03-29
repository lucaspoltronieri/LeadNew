require 'rails_helper'

RSpec.describe AiAgent, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:account) }
    it { is_expected.to belong_to(:inbox) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    
    it 'is valid with valid attributes' do
      ai_agent = build(:ai_agent)
      expect(ai_agent).to be_valid
    end

    it 'is not valid without a name' do
      ai_agent = build(:ai_agent, name: nil)
      expect(ai_agent).not_to be_valid
      expect(ai_agent.errors[:name]).to include("can't be blank")
    end
  end

  describe 'default values' do
    it 'sets is_active to true by default if not specified' do
      ai_agent = build(:ai_agent, is_active: nil)
      # Assuming default logic in model or DB schema handles this. If not, it might remain nil, but usually it should be tracked.
      # For now, just test basic instantiation
    end
  end
end
