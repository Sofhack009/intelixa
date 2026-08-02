class Item < ApplicationRecord
  has_many :stocked_inventory_batches, -> { in_stock }, class_name: "InventoryBatch"

  has_many :inventory_batches, dependent: :restrict_with_error
  has_many :job_work_items, dependent: :restrict_with_error
  has_many :wastage_logs, dependent: :restrict_with_error
  has_many :quality_inspections, dependent: :restrict_with_error

  validates :sku_code, :name, :item_type, presence: true
  validates :sku_code, uniqueness: true
  validates :min_stock_level, numericality: { greater_than_or_equal_to: 0, only_integer: true }, allow_nil: true

  scope :with_stock_totals, lambda {
    left_joins(:inventory_batches)
      .select("items.*, COALESCE(SUM(inventory_batches.quantity), 0) AS stock_on_hand")
      .group("items.id")
  }

  scope :low_stock, lambda {
    left_joins(:inventory_batches)
      .where("items.min_stock_level > 0")
      .group("items.id", "items.min_stock_level")
      .having("COALESCE(SUM(inventory_batches.quantity), 0) <= items.min_stock_level")
  }

  def stock_on_hand
    inventory_batches.sum(:quantity)
  end

  def low_stock?
    min_stock_level.to_i.positive? && stock_on_hand <= min_stock_level
  end
end
