class CreateAccountBillings < ActiveRecord::Migration[7.0]
  def change
    create_table :account_billings do |t|
      t.references :account, null: false, foreign_key: true, index: { unique: true }
      t.string :asaas_customer_id
      t.string :subscription_status, default: 'pending'
      t.string :plan_type

      t.timestamps
    end
  end
end
