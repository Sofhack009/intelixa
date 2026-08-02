class HardenInventoryDomainConstraints < ActiveRecord::Migration[8.0]
  def change
    add_index :warehouses, :name, unique: true, if_not_exists: true
    add_index :job_workers, [:name, :process_type], unique: true, if_not_exists: true

    add_check_constraint :job_work_items,
                         "quantity_issued > 0",
                         name: "job_work_items_quantity_issued_positive"
    add_check_constraint :job_work_items,
                         "quantity_received >= 0",
                         name: "job_work_items_quantity_received_non_negative"
    add_check_constraint :job_work_items,
                         "quantity_scrapped >= 0",
                         name: "job_work_items_quantity_scrapped_non_negative"
    add_check_constraint :job_work_items,
                         "quantity_received + quantity_scrapped <= quantity_issued",
                         name: "job_work_items_output_not_over_issued"

    add_check_constraint :quality_inspections,
                         "quantity_inspected >= 0",
                         name: "quality_inspections_quantity_inspected_non_negative"
    add_check_constraint :quality_inspections,
                         "quantity_approved >= 0",
                         name: "quality_inspections_quantity_approved_non_negative"
    add_check_constraint :quality_inspections,
                         "quantity_rejected >= 0",
                         name: "quality_inspections_quantity_rejected_non_negative"
    add_check_constraint :quality_inspections,
                         "quantity_approved + quantity_rejected <= quantity_inspected",
                         name: "quality_inspections_output_not_over_inspected"

    add_check_constraint :wastage_logs,
                         "quantity_wasted > 0",
                         name: "wastage_logs_quantity_positive"
    add_check_constraint :wastage_logs,
                         "estimated_cost >= 0",
                         name: "wastage_logs_estimated_cost_non_negative"

    add_check_constraint :job_workers,
                         "rate_per_unit >= 0",
                         name: "job_workers_rate_non_negative"
  end
end
