class JobWorkItem < ApplicationRecord
  belongs_to :job_work_challan
  belongs_to :item

  validates :quantity_issued, numericality: { greater_than: 0, only_integer: true }
  validates :quantity_received, :quantity_scrapped, numericality: { greater_than_or_equal_to: 0, only_integer: true }, allow_nil: true
end
