class WastageLog < ApplicationRecord
  belongs_to :item
  belongs_to :warehouse, optional: true
  belongs_to :created_by, class_name: "User", optional: true

  validates :quantity_wasted, numericality: { greater_than: 0, only_integer: true }
  validates :reason_code, presence: true
  validates :estimated_cost, numericality: { greater_than_or_equal_to: 0 }
end
