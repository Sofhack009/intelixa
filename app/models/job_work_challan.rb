class JobWorkChallan < ApplicationRecord
  belongs_to :job_worker
  has_many :job_work_items, dependent: :restrict_with_error

  validates :expected_return_date, presence: true
  validates :status, presence: true
end
