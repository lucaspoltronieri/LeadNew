class CreateCrmDeals < ActiveRecord::Migration[7.0]
  def change
    create_table :crm_deals do |t|
      t.references :account,      null: false, foreign_key: true
      t.references :crm_stage,    null: false, foreign_key: true
      t.references :contact,      null: false, foreign_key: true
      t.references :conversation, null: true,  foreign_key: true
      t.string  :title,       null: false
      t.decimal :value,       precision: 12, scale: 2, default: 0
      t.integer :status,      null: false, default: 0
      t.text    :lost_reason

      t.timestamps
    end

    add_index :crm_deals, [:account_id, :crm_stage_id]
    add_index :crm_deals, [:account_id, :status]
  end
end
