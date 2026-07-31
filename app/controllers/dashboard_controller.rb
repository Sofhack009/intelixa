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
    @recent_movements = InventoryBatch.includes(:item, :warehouse).order(created_at: :desc).limit(5)

    # ==========================================
    # Kanban & Needs Attention Queries
    # ==========================================
    
    # Base query: Get all incomplete job work challans
    active_jobs = JobWorkChallan.includes(:job_worker).where.not(status: 'Completed')
    
    # Categorize by expected return date & status
    @kanban_overdue = active_jobs.where("expected_return_date < ?", Time.current.beginning_of_day)
                                 .order(expected_return_date: :asc)
    
    @kanban_today = active_jobs.where(expected_return_date: Time.current.beginning_of_day..Time.current.end_of_day)
                               .order(expected_return_date: :asc)
                               
    # "Working" implies tasks that are currently actively being processed (Pending but not overdue)
    @kanban_working = active_jobs.where(status: 'Pending')
                                 .where("expected_return_date > ?", Time.current.end_of_day)
                                 .order(expected_return_date: :asc)
    
    # Upcoming mapped to anything due further out in the future (e.g., > 3 days)
    @kanban_upcoming = active_jobs.where("expected_return_date > ?", Time.current.advance(days: 3).end_of_day)
                                  .order(expected_return_date: :asc)
    
    # Needs attention limit for the top alert box
    @needs_attention = @kanban_overdue.limit(15)
  end
end