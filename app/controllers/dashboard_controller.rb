class DashboardController < ApplicationController
  def index
    summary = Dashboard::Summary.new

    @inventory_value = summary.inventory_value
    @active_items_count = summary.active_items_count
    @alerts_count = summary.alerts_count
    @pending_challans = summary.pending_challans
    @warehouse_breakdown = summary.warehouse_breakdown
    @recent_movements = summary.recent_movements
    @kanban_overdue = summary.kanban_overdue
    @kanban_today = summary.kanban_today
    @kanban_working = summary.kanban_working
    @kanban_upcoming = summary.kanban_upcoming
    @needs_attention = summary.needs_attention
  end
end
