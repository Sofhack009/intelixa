class AddWastageContextAndInspectorFk < ActiveRecord::Migration[8.0]
  def change
    add_reference :wastage_logs, :warehouse, foreign_key: true
    add_reference :wastage_logs, :created_by, foreign_key: { to_table: :users }
    add_foreign_key :quality_inspections, :users, column: :inspected_by
    add_index :quality_inspections, :inspected_by
  end
end
