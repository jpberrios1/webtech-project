class Amenity < ApplicationRecord
  has_many :property_amenities, dependent: :destroy
  has_many :properties, through: :property_amenities

  validates :name, presence: true, length: { maximum: 80 }, uniqueness: { case_sensitive: false }
end
