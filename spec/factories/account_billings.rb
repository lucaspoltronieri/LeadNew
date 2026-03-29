FactoryBot.define do
  factory :account_billing do
    account
    sequence(:asaas_customer_id) { |n| "cus_#{n.to_s.rjust(12, '0')}" }
    subscription_status { 'pending' }
    plan_type { 'starter' }
  end
end
