class Item < ApplicationRecord
  has_many :inventory_batches, dependent: :restrict_with_error
  has_many :job_work_items, dependent: :restrict_with_error
  has_many :wastage_logs, dependent: :restrict_with_error
  has_many :quality_inspections, dependent: :restrict_with_error

  validates :sku_code, :name, :item_type, presence: true
  validates :sku_code, uniqueness: true
  validates :min_stock_level, numericality: { greater_than_or_equal_to: 0, only_integer: true }, allow_nil: true
end
