class CreateQualityInspections < ActiveRecord::Migration[8.0]
  def change
    create_table :quality_inspections do |t|
      t.references :source, polymorphic: true, null: false # Connects to JobWorkChallans or Internal Production
      t.references :item, null: false, foreign_key: true
      t.integer :quantity_inspected, null: false
      t.integer :quantity_approved, null: false
      t.integer :quantity_rejected, null: false
      t.integer :inspected_by
      t.string :status, null: false

      t.timestamps
    end
  end
end
