FactoryBot.define do
  factory :token_ledger do
    account
    tokens_purchased { 1000 }
    tokens_used { 0 }
    balance { 1000 }
  end
end
