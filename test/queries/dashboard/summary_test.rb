require "test_helper"

class Dashboard::SummaryTest < ActiveSupport::TestCase
  test "calculates inventory value excluding trading products" do
    summary = Dashboard::Summary.new

    assert_equal InventoryBatch.valued_for_dashboard.sum("inventory_batches.quantity * inventory_batches.unit_cost"), summary.inventory_value
  end

  test "groups overdue challans into needs attention" do
    challan = job_work_challans(:one)
    challan.update!(status: "Pending", expected_return_date: 1.day.ago)

    assert_includes Dashboard::Summary.new.needs_attention, challan
  end
end
