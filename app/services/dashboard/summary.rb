module Dashboard
  class Summary
    def inventory_value
      InventoryBatch.valued_for_dashboard.sum("inventory_batches.quantity * inventory_batches.unit_cost")
    end

    def active_items_count
      Item.where.not(item_type: "trading_product").count
    end

    def alerts_count
      Item.low_stock.count
    end

    def pending_challans
      JobWorkChallan.where(status: "Pending").count
    end

    def warehouse_breakdown
      InventoryBatch.valued_for_dashboard
        .joins(:warehouse)
        .group("warehouses.id", "warehouses.name")
        .sum("inventory_batches.quantity * inventory_batches.unit_cost")
    end

    def recent_movements
      InventoryBatch.includes(:item, :warehouse).order(updated_at: :desc).limit(10)
    end

    def kanban_overdue
      JobWorkChallan.active.overdue.order(expected_return_date: :asc)
    end

    def kanban_today
      JobWorkChallan.active.due_on(Time.zone.today).order(expected_return_date: :asc)
    end

    def kanban_working
      JobWorkChallan.where(status: "In Progress").order(expected_return_date: :asc)
    end

    def kanban_upcoming
      JobWorkChallan.active
        .where(expected_return_date: Time.zone.tomorrow.beginning_of_day..30.days.from_now.end_of_day)
        .order(expected_return_date: :asc)
    end

    def needs_attention
      JobWorkChallan.active.overdue.order(expected_return_date: :asc).limit(5)
    end
  end
end
