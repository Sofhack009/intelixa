require "test_helper"

class Dashboard::SummaryTest < ActiveSupport::TestCase
  test "counts actual low stock items" do
    item = Item.create!(sku_code: "SKU-DASH", name: "Dashboard Item", item_type: "raw_material", min_stock_level: 10)
    warehouse = Warehouse.create!(name: "Dashboard Warehouse")
    InventoryBatch.create!(item: item, warehouse: warehouse, batch_number: "D-1", quantity: 4, unit_cost: 20)

    assert_equal 1, Dashboard::Summary.new.alerts_count
  end
end
