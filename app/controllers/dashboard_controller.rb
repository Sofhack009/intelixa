class DashboardController < ApplicationController
  def index
    @inventory_value = valued_batches.sum("inventory_batches.quantity * inventory_batches.unit_cost")
    @active_items_count = Item.count
    @alerts_count = low_stock_items.count.size
    @pending_challans = active_jobs.where(status: %w[Pending Overdue]).count
    @warehouse_breakdown = warehouse_breakdown
    @recent_movements = InventoryBatch.includes(:item, :warehouse).order(created_at: :desc).limit(5)

    @kanban_overdue = active_jobs.where("expected_return_date < ?", Time.zone.today.beginning_of_day)
                                  .order(expected_return_date: :asc)
                                  .limit(20)
    @kanban_today = active_jobs.where(expected_return_date: Time.current.all_day)
                               .order(expected_return_date: :asc)
                               .limit(20)
    @kanban_working = active_jobs.where(status: "Pending")
                                 .where("expected_return_date > ?", Time.current.end_of_day)
                                 .where("expected_return_date <= ?", 3.days.from_now.end_of_day)
                                 .order(expected_return_date: :asc)
                                 .limit(20)
    @kanban_upcoming = active_jobs.where("expected_return_date > ?", 3.days.from_now.end_of_day)
                                  .order(expected_return_date: :asc)
                                  .limit(20)
    @needs_attention = @kanban_overdue.limit(15)
  end

  private

  def valued_batches
    @valued_batches ||= InventoryBatch.joins(:item)
                                      .where.not(items: { item_type: "trading_product" })
  end

  def low_stock_items
    Item.left_joins(:inventory_batches)
        .where("items.min_stock_level > 0")
        .group("items.id", "items.min_stock_level")
        .having("COALESCE(SUM(inventory_batches.quantity), 0) <= items.min_stock_level")
  end

  def active_jobs
    @active_jobs ||= JobWorkChallan.includes(:job_worker).where.not(status: "Completed")
  end

  def warehouse_breakdown
    valued_batches.joins(:warehouse)
                  .group("warehouses.name")
                  .sum("inventory_batches.quantity * inventory_batches.unit_cost")
                  .sort_by { |_, value| -value.to_d }
  end
end
