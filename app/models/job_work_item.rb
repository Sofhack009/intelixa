class JobWorkItem < ApplicationRecord
  belongs_to :job_work_challan
  belongs_to :item

  validates :quantity_issued, numericality: { greater_than: 0, only_integer: true }
  validates :quantity_received, :quantity_scrapped,
            numericality: { greater_than_or_equal_to: 0, only_integer: true }
  validate :received_and_scrapped_cannot_exceed_issued

  private

  def received_and_scrapped_cannot_exceed_issued
    received = quantity_received.to_i
    scrapped = quantity_scrapped.to_i
    issued = quantity_issued.to_i

    return if issued <= 0

    if received + scrapped > issued
      errors.add(:base, "received and scrapped quantities cannot exceed issued quantity")
    end
  end
end
