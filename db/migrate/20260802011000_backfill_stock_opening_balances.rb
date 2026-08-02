class BackfillStockOpeningBalances < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def up
    execute <<~SQL
      INSERT INTO stock_movements
        (item_id, warehouse_id, movement_type, quantity_delta, unit_cost, occurred_at, created_at, updated_at)
      SELECT
        item_id,
        warehouse_id,
        'opening_balance',
        quantity,
        unit_cost,
        created_at,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
      FROM inventory_batches
      WHERE quantity <> 0
    SQL
  end

  def down
    execute <<~SQL
      DELETE FROM stock_movements
      WHERE movement_type = 'opening_balance'
    SQL
  end
end
