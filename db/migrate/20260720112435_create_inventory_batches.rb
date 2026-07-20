class CreateInventoryBatches < ActiveRecord::Migration[8.0]
  def change
    create_table :inventory_batches do |t|
      t.references :item, null: false, foreign_key: true
      t.references :warehouse, null: false, foreign_key: true
      t.string :batch_number, null: false
      t.integer :quantity, default: 0, null: false
      t.decimal :unit_cost, precision: 12, scale: 2, null: false
      t.date :expiry_date

      t.timestamps
    end
  end
end
