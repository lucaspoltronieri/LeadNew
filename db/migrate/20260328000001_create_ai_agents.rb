class CreateAiAgents < ActiveRecord::Migration[7.0]
  def change
    create_table :ai_agents do |t|
      t.references :account, null: false, foreign_key: true
      t.references :inbox, null: false, foreign_key: true
      t.string :name, null: false
      t.text :system_prompt
      t.boolean :is_active, default: true, null: false

      t.timestamps
    end

    add_index :ai_agents, [:account_id, :inbox_id]
  end
end
