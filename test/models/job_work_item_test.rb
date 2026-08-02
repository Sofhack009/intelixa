require "test_helper"

class JobWorkItemTest < ActiveSupport::TestCase
  test "rejects received and scrapped quantities above issued" do
    item = Item.create!(sku_code: "SKU-JW", name: "Job Work Item", item_type: "raw_material", min_stock_level: 0)
    worker = JobWorker.create!(name: "Worker", process_type: "Finishing", rate_per_unit: 2)
    challan = JobWorkChallan.create!(job_worker: worker, expected_return_date: 2.days.from_now, status: "Pending")

    job_work_item = JobWorkItem.new(
      job_work_challan: challan,
      item: item,
      quantity_issued: 10,
      quantity_received: 8,
      quantity_scrapped: 3
    )

    assert_not job_work_item.valid?
    assert_includes job_work_item.errors[:base], "received and scrapped quantities cannot exceed issued quantity"
  end

  test "accepts received and scrapped quantities within issued" do
    item = Item.create!(sku_code: "SKU-JW-2", name: "Job Work Item 2", item_type: "raw_material", min_stock_level: 0)
    worker = JobWorker.create!(name: "Worker 2", process_type: "Cutting", rate_per_unit: 2)
    challan = JobWorkChallan.create!(job_worker: worker, expected_return_date: 2.days.from_now, status: "Pending")

    job_work_item = JobWorkItem.new(
      job_work_challan: challan,
      item: item,
      quantity_issued: 10,
      quantity_received: 8,
      quantity_scrapped: 2
    )

    assert_predicate job_work_item, :valid?
  end
end
