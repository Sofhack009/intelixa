class JobWorkItem < ApplicationRecord
  belongs_to :job_work_challan
  belongs_to :item
end
