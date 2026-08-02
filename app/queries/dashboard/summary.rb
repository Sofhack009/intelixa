module Dashboard
  class Summary
    KANBAN_LIMIT = 20
    ATTENTION_LIMIT = 15

    attr_reader :today

    def initialize(today: Time.zone.today)
      @today = today
    end

    def inventory_value
      valued_batches.sum("inventory_batches.quantity * inventory_batches.unit_cost")
    end

    def active_items_count
      Item.count
    end

    def alerts_count
      low_stock_items.count.size
    end

    def pending_challans
      active_jobs.where(status: %w[Pending Overdue]).count
    end

    def warehouse_breakdown
      valued_batches.joins(:warehouse)
                    .group("warehouses.name")
                    .sum("inventory_batches.quantity * inventory_batches.unit_cost")
                    .sort_by { |_, value| -value.to_d }
    end

    def recent_movements
      InventoryBatch.includes(:item, :warehouse).order(created_at: :desc).limit(5)
    end

    def kanban_overdue
      active_jobs.overdue(today).order(expected_return_date: :asc).limit(KANBAN_LIMIT)
    end

    def kanban_today
      active_jobs.due_on(today).order(expected_return_date: :asc).limit(KANBAN_LIMIT)
    end

    def kanban_working
      active_jobs.where(status: "Pending")
                 .where("expected_return_date > ?", today.end_of_day)
                 .where("expected_return_date <= ?", 3.days.after(today).end_of_day)
                 .order(expected_return_date: :asc)
                 .limit(KANBAN_LIMIT)
    end

    def kanban_upcoming
      active_jobs.where("expected_return_date > ?", 3.days.after(today).end_of_day)
                 .order(expected_return_date: :asc)
                 .limit(KANBAN_LIMIT)
    end

    def needs_attention
      kanban_overdue.limit(ATTENTION_LIMIT)
    end

    private

    def valued_batches
      @valued_batches ||= InventoryBatch.valued_for_dashboard
    end

    def low_stock_items
      @low_stock_items ||= Item.low_stock
    end

    def active_jobs
      @active_jobs ||= JobWorkChallan.active.includes(:job_worker)
    end
  end
end
