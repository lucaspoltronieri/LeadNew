class CreateCrmPipelines < ActiveRecord::Migration[7.0]
  def change
    create_table :crm_pipelines do |t|
      t.references :account, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description

      t.timestamps
    end

    add_index :crm_pipelines, [:account_id, :name], unique: true
  end
end
