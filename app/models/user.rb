class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  ROLES = %w[operator admin].freeze

  has_many :stock_movements, foreign_key: :created_by_id, dependent: :restrict_with_error
  has_many :wastage_logs, foreign_key: :created_by_id, dependent: :restrict_with_error
  has_many :quality_inspections, foreign_key: :inspected_by, dependent: :restrict_with_error

  validates :role, presence: true, inclusion: { in: ROLES }

  def admin?
    role == "admin"
  end
end
