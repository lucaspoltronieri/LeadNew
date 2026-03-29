FactoryBot.define do
  factory :crm_deal do
    account
    crm_stage
    contact
    sequence(:title) { |n| "Oportunidade #{n}" }
    value { 1000.00 }
    status { :open }
  end
end
