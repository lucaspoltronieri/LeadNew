# == Schema Information
#
# Table name: ai_agents
#
#  id            :bigint           not null, primary key
#  account_id    :bigint           not null
#  inbox_id      :bigint           not null
#  name          :string
#  system_prompt :text
#  is_active     :boolean          default(TRUE)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class AiAgent < ApplicationRecord
  belongs_to :account
  belongs_to :inbox

  validates :name, presence: true
  validates :inbox_id, presence: true

  def push_event_data(inbox = nil)
    {
      id: id,
      name: name,
      type: 'ai_agent'
    }
  end

  def webhook_data
    {
      id: id,
      name: name,
      type: 'ai_agent'
    }
  end
end
