class DashboardController < ApplicationController
  # This line intercepts anyone not logged in and sends them to the Devise login page
  before_action :authenticate_user!

  def index
    valued_batches = InventoryBatch.joins(:item)
                                   .where.not(items: { item_type: "trading_product" })

    # 1. Total Inventory Value (Items * Unit Cost)
    @inventory_value = valued_batches.sum("inventory_batches.quantity * inventory_batches.unit_cost")

    # 2. Active Items Count
    @active_items_count = Item.count

    # 3. Active Smart Alerts (Simulated for MVP)
    @alerts_count = Item.where("min_stock_level > ?", 0).count # Replace with actual low stock query

    # 4. Pending / overdue job work challans
    @pending_challans = JobWorkChallan.where(status: %w[Pending Overdue]).count

    # 5. Warehouse valuation breakdown for the sidebar chart
    @warehouse_breakdown = valued_batches.joins(:warehouse)
                                         .group("warehouses.name")
                                         .sum("inventory_batches.quantity * inventory_batches.unit_cost")
                                         .sort_by { |_, value| -value }

    # 6. Recent Activity (Last 5 Stock Movements)
    # .includes(:item, :warehouse) avoids an N+1 query since the view renders
    # batch.item.name and batch.warehouse.name for every row.
    @recent_movements = InventoryBatch.includes(:item, :warehouse).order(created_at: :desc).limit(5)
  end
end