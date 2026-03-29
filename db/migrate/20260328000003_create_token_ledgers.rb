class CreateTokenLedgers < ActiveRecord::Migration[7.0]
  def change
    create_table :token_ledgers do |t|
      t.references :account, null: false, foreign_key: true, index: { unique: true }
      t.integer :tokens_purchased, default: 0, null: false
      t.integer :tokens_used, default: 0, null: false
      t.integer :balance, default: 0, null: false

      t.timestamps
    end
  end
end
