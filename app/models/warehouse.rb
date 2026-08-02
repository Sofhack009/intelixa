class Warehouse < ApplicationRecord
  has_many :inventory_batches, dependent: :restrict_with_error
  has_many :stock_movements, dependent: :restrict_with_error
  has_many :wastage_logs, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true
end
