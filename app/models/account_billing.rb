# == Schema Information
#
# Table name: account_billings
#
#  id                  :bigint           not null, primary key
#  account_id          :bigint           not null
#  asaas_customer_id   :string
#  subscription_status :string
#  plan_type           :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class AccountBilling < ApplicationRecord
  belongs_to :account

  validates :asaas_customer_id, presence: true
  
  # Status helper methods
  def active?
    subscription_status == 'active'
  end

  def suspended?
    subscription_status == 'suspended'
  end
end
