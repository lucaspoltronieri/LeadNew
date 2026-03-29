# == Schema Information
#
# Table name: crm_deals
#
#  id              :bigint           not null, primary key
#  account_id      :bigint           not null
#  crm_stage_id    :bigint           not null
#  contact_id      :bigint           not null
#  conversation_id :bigint
#  title           :string           not null
#  value           :decimal(12,2)    default(0)
#  status          :integer          default(0), not null
#  lost_reason     :text
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class CrmDeal < ApplicationRecord
  belongs_to :account
  belongs_to :crm_stage
  belongs_to :contact
  belongs_to :conversation, optional: true

  has_one :crm_pipeline, through: :crm_stage

  enum :status, { open: 0, won: 1, lost: 2 }

  validates :title, presence: true
  validates :value, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :lost_reason, presence: true, if: :lost?

  scope :for_pipeline, ->(pipeline_id) {
    joins(:crm_stage).where(crm_stages: { crm_pipeline_id: pipeline_id })
  }
end
