require 'administrate/base_dashboard'

class TokenLedgerDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    account: Field::BelongsTo,
    tokens_purchased: Field::Number,
    tokens_used: Field::Number,
    balance: Field::Number,
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    id
    account
    tokens_purchased
    tokens_used
    balance
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    account
    tokens_purchased
    tokens_used
    balance
    created_at
    updated_at
  ].freeze

  FORM_ATTRIBUTES = %i[
    tokens_purchased
    tokens_used
  ].freeze

  def display_resource(token_ledger)
    "TokenLedger ##{token_ledger.id}"
  end
end
