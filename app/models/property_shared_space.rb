class PropertySharedSpace < ApplicationRecord
  belongs_to :property
  belongs_to :shared_space

  validates :property_id, uniqueness: { scope: :shared_space_id }
end
