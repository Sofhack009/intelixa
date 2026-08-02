class Warehouse < ApplicationRecord
  has_many :inventory_batches, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true
end
