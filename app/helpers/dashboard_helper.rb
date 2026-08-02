module DashboardHelper
  def challan_reference(challan)
    "CH-#{challan.id.to_s.rjust(4, '0')}"
  end

  def job_worker_name(challan)
    challan.job_worker&.name.presence || "Unassigned"
  end

  def job_worker_process(challan)
    challan.job_worker&.process_type.presence || "Job work"
  end

  def motor_admin_record_path(resource, id = nil)
    [ "/motor_admin/data", resource, id ].compact.join("/")
  end
end
