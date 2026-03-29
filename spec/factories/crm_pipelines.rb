FactoryBot.define do
  factory :crm_pipeline do
    account
    sequence(:name) { |n| "Pipeline #{n}" }
    description { 'Pipeline de vendas padrão' }
  end
end
