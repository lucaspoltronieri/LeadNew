class CreateCrmStages < ActiveRecord::Migration[7.0]
  def change
    create_table :crm_stages do |t|
      t.references :crm_pipeline, null: false, foreign_key: true
      t.string :name, null: false
      t.integer :position, null: false, default: 0
      t.string :color, default: '#6366f1'

      t.timestamps
    end

    add_index :crm_stages, [:crm_pipeline_id, :position]
  end
end
