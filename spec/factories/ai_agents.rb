FactoryBot.define do
  factory :ai_agent do
    account
    inbox
    sequence(:name) { |n| "Agente Inteligente #{n}" }
    system_prompt { "Você é o {agente_nome}, um atendente virtual muito educado." }
    is_active { true }
  end
end
