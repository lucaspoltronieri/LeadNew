FactoryBot.define do
  factory :crm_stage do
    crm_pipeline
    sequence(:name) { |n| "Etapa #{n}" }
    sequence(:position) { |n| n }
    color { '#6366f1' }
  end
end
