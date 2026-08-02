class JobWorker < ApplicationRecord
  has_many :job_work_challans, dependent: :restrict_with_error

  validates :name, :process_type, presence: true
  validates :rate_per_unit, numericality: { greater_than_or_equal_to: 0 }
end
