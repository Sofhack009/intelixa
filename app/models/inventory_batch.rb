class InventoryBatch < ApplicationRecord
  belongs_to :item
  belongs_to :warehouse

  validates :batch_number, presence: true
  validates :quantity, numericality: { greater_than_or_equal_to: 0, only_integer: true }
  validates :unit_cost, numericality: { greater_than_or_equal_to: 0 }
end
