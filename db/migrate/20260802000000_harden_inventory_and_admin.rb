class HardenInventoryAndAdmin < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :role, :string, null: false, default: "operator"
    add_index :users, :role

    add_index :items, :item_type
    add_index :items, :min_stock_level
    add_index :inventory_batches, [ :item_id, :warehouse_id, :batch_number ], unique: true, name: "index_inventory_batches_unique_batch_per_location"
    add_index :job_work_challans, [ :status, :expected_return_date ]

    add_check_constraint :items, "min_stock_level >= 0", name: "items_min_stock_level_non_negative"
    add_check_constraint :inventory_batches, "quantity >= 0", name: "inventory_batches_quantity_non_negative"
    add_check_constraint :inventory_batches, "unit_cost >= 0", name: "inventory_batches_unit_cost_non_negative"
  end
end
