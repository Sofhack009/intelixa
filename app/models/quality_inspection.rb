class QualityInspection < ApplicationRecord
  belongs_to :source, polymorphic: true
  belongs_to :item
end
