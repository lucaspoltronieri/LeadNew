# == Schema Information
#
# Table name: crm_pipelines
#
#  id          :bigint           not null, primary key
#  account_id  :bigint           not null
#  name        :string           not null
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class CrmPipeline < ApplicationRecord
  belongs_to :account
  has_many :crm_stages, -> { order(position: :asc) }, dependent: :destroy
  has_many :crm_deals, through: :crm_stages

  validates :name, presence: true
  validates :name, uniqueness: { scope: :account_id }
end
