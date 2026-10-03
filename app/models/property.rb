class Property < ApplicationRecord
  belongs_to :user
  belongs_to :neighborhood

  has_many :property_amenities, dependent: :destroy
  has_many :amenities, through: :property_amenities
  has_many :property_shared_spaces, dependent: :destroy
  has_many :shared_spaces, through: :property_shared_spaces
  has_many :listings, dependent: :destroy
  has_many :reviews, dependent: :destroy

  scope :with_details, -> { includes(:neighborhood, :listings, reviews: :user) }

  enum :property_type, {
    house: "house",
    apartment: "apartment",
    other: "other"
  }

  validates :title, presence: true, length: { maximum: 150 }
  validates :address, presence: true, length: { maximum: 255 }
  validates :bedrooms,  presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :bathrooms, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
