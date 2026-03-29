require 'administrate/base_dashboard'

class AccountBillingDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    account: Field::BelongsTo,
    asaas_customer_id: Field::String,
    subscription_status: Field::String,
    plan_type: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    id
    account
    subscription_status
    plan_type
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    account
    asaas_customer_id
    subscription_status
    plan_type
    created_at
    updated_at
  ].freeze

  FORM_ATTRIBUTES = %i[
    subscription_status
    plan_type
  ].freeze

  def display_resource(account_billing)
    "AccountBilling ##{account_billing.id}"
  end
end
