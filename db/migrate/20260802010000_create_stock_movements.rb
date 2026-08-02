class CreateStockMovements < ActiveRecord::Migration[8.0]
  def change
    create_table :stock_movements do |t|
      t.references :item, null: false, foreign_key: true
      t.references :warehouse, null: false, foreign_key: true
      t.string :movement_type, null: false
      t.integer :quantity_delta, null: false
      t.decimal :unit_cost, precision: 12, scale: 2, null: false, default: 0
      t.references :created_by, null: true, foreign_key: { to_table: :users }
      t.string :reference_type
      t.bigint :reference_id
      t.datetime :occurred_at, null: false, default: -> { "CURRENT_TIMESTAMP" }
      t.timestamps
    end

    add_index :stock_movements, [:reference_type, :reference_id]
    add_index :stock_movements, [:item_id, :warehouse_id, :occurred_at]
    add_index :stock_movements, :movement_type
    add_check_constraint :stock_movements, "quantity_delta <> 0", name: "stock_movements_quantity_delta_non_zero"
    add_check_constraint :stock_movements, "unit_cost >= 0", name: "stock_movements_unit_cost_non_negative"
  end
end
