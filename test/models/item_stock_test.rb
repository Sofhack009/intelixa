require "test_helper"

class ItemStockTest < ActiveSupport::TestCase
  test "stock_on_hand sums inventory batch quantities" do
    assert_equal 1, items(:one).stock_on_hand
  end

  test "low_stock identifies items at or below minimum level" do
    item = Item.create!(sku_code: "LOW-001", name: "Low Stock", item_type: "raw_material", min_stock_level: 10)
    InventoryBatch.create!(item: item, warehouse: warehouses(:one), batch_number: "LOW-A", quantity: 10, unit_cost: 5)

    assert_predicate item, :low_stock?
    assert_includes Item.low_stock, item
  end
end
