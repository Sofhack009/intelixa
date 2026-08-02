class StockMovement < ApplicationRecord
  MOVEMENT_TYPES = %w[
    opening_balance
    purchase
    receipt
    sale
    issue
    transfer_in
    transfer_out
    job_work_issue
    job_work_return
    wastage
    adjustment
  ].freeze

  belongs_to :item
  belongs_to :warehouse
  belongs_to :created_by, class_name: "User", optional: true
  belongs_to :reference, polymorphic: true, optional: true

  validates :movement_type, presence: true, inclusion: { in: MOVEMENT_TYPES }
  validates :quantity_delta, numericality: { other_than: 0, only_integer: true }
  validates :unit_cost, numericality: { greater_than_or_equal_to: 0 }
  validates :occurred_at, presence: true

  scope :chronological, -> { order(occurred_at: :asc, id: :asc) }
end
