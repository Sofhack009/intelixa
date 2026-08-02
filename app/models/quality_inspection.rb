class QualityInspection < ApplicationRecord
  belongs_to :source, polymorphic: true
  belongs_to :item
  belongs_to :inspector, class_name: "User", foreign_key: :inspected_by, optional: true

  validates :quantity_inspected, :quantity_approved, :quantity_rejected,
            numericality: { greater_than_or_equal_to: 0, only_integer: true }
  validate :approved_and_rejected_cannot_exceed_inspected

  private

  def approved_and_rejected_cannot_exceed_inspected
    inspected = quantity_inspected.to_i
    approved = quantity_approved.to_i
    rejected = quantity_rejected.to_i

    if approved + rejected > inspected
      errors.add(:base, "approved and rejected quantities cannot exceed inspected quantity")
    end
  end
end
