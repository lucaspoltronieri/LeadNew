# == Schema Information
#
# Table name: crm_stages
#
#  id              :bigint           not null, primary key
#  crm_pipeline_id :bigint           not null
#  name            :string           not null
#  position        :integer          default(0), not null
#  color           :string           default("#6366f1")
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class CrmStage < ApplicationRecord
  belongs_to :crm_pipeline
  has_many :crm_deals, dependent: :destroy

  delegate :account, :account_id, to: :crm_pipeline

  validates :name, presence: true
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
