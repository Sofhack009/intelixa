class InventoryBatch < ApplicationRecord
  belongs_to :item
  belongs_to :warehouse

  validates :batch_number, presence: true
  validates :quantity, numericality: { greater_than_or_equal_to: 0, only_integer: true }
  validates :unit_cost, numericality: { greater_than_or_equal_to: 0 }
  validates :batch_number, uniqueness: { scope: [ :item_id, :warehouse_id ] }

  scope :in_stock, -> { where("quantity > 0") }
  scope :valued_for_dashboard, lambda {
    joins(:item).where.not(items: { item_type: "trading_product" })
  }

  def stock_value
    quantity * unit_cost
  end
end
