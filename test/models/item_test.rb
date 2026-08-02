require "test_helper"

class ItemTest < ActiveSupport::TestCase
  test "requires core fields" do
    item = Item.new

    assert_not item.valid?
    assert_includes item.errors[:sku_code], "can't be blank"
    assert_includes item.errors[:name], "can't be blank"
    assert_includes item.errors[:item_type], "can't be blank"
  end

  test "rejects negative minimum stock" do
    item = Item.new(sku_code: "SKU-TEST", name: "Test Item", item_type: "raw_material", min_stock_level: -1)

    assert_not item.valid?
    assert_includes item.errors[:min_stock_level], "must be greater than or equal to 0"
  end

  test "reports low stock from inventory batches" do
    item = Item.create!(sku_code: "SKU-LOW", name: "Low Stock", item_type: "raw_material", min_stock_level: 10)
    warehouse = Warehouse.create!(name: "Test Warehouse")
    InventoryBatch.create!(item: item, warehouse: warehouse, batch_number: "B-1", quantity: 5, unit_cost: 10)

    assert item.low_stock?
    assert_equal 5, item.stock_on_hand
    assert_includes Item.low_stock, item
  end
end
