class JobWorkChallan < ApplicationRecord
  belongs_to :job_worker
  has_many :job_work_items, dependent: :restrict_with_error

  validates :expected_return_date, presence: true
  validates :status, presence: true

  scope :active, -> { where.not(status: "Completed") }
  scope :overdue, ->(date = Time.zone.today) { where("expected_return_date < ?", date.beginning_of_day) }
  scope :due_on, ->(date) { where(expected_return_date: date.all_day) }
end
