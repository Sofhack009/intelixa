require "test_helper"

class Inventory::StockAdjustmentTest < ActiveSupport::TestCase
  test "creates a batch and ledger movement for positive adjustment" do
    item = Item.create!(sku_code: "SKU-ADJ", name: "Adjustment Item", item_type: "raw_material", min_stock_level: 0)
    warehouse = Warehouse.create!(name: "Adjustment Warehouse")

    result = Inventory::StockAdjustment.call(
      item: item,
      warehouse: warehouse,
      batch_number: "B-ADJ",
      quantity_delta: 10,
      movement_type: "receipt",
      unit_cost: 25
    )

    assert_equal 10, result.batch.quantity
    assert_equal 10, result.movement.quantity_delta
    assert_equal "receipt", result.movement.movement_type
  end

  test "rejects an adjustment that would make stock negative" do
    item = Item.create!(sku_code: "SKU-ADJ-2", name: "Adjustment Item 2", item_type: "raw_material", min_stock_level: 0)
    warehouse = Warehouse.create!(name: "Adjustment Warehouse 2")
    InventoryBatch.create!(item: item, warehouse: warehouse, batch_number: "B-ADJ-2", quantity: 3, unit_cost: 25)

    assert_raises(ActiveRecord::RecordInvalid) do
      Inventory::StockAdjustment.call(
        item: item,
        warehouse: warehouse,
        batch_number: "B-ADJ-2",
        quantity_delta: -4,
        movement_type: "issue",
        unit_cost: 25
      )
    end

    assert_equal 3, InventoryBatch.find_by(batch_number: "B-ADJ-2").quantity
    assert_not StockMovement.exists?(item: item, warehouse: warehouse, quantity_delta: -4)
  end
end
