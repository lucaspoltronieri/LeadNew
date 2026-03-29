# == Schema Information
#
# Table name: token_ledgers
#
#  id               :bigint           not null, primary key
#  account_id       :bigint           not null
#  tokens_purchased :integer          default(0)
#  tokens_used      :integer          default(0)
#  balance          :integer          default(0)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class TokenLedger < ApplicationRecord
  belongs_to :account

  before_save :update_balance

  def calculate_balance
    (tokens_purchased || 0) - (tokens_used || 0)
  end

  def credit!(amount)
    return if amount.to_i <= 0

    with_lock do
      self.tokens_purchased = (self.tokens_purchased || 0) + amount.to_i
      update_balance # Force update immediately within the lock
      save!
    end
  end

  def debit!(amount)
    return if amount.to_i <= 0

    with_lock do
      self.tokens_used = (self.tokens_used || 0) + amount.to_i
      update_balance # Force update immediately within the lock
      save!
    end
  end

  private

  def update_balance
    self.balance = (tokens_purchased || 0) - (tokens_used || 0)
  end
end
