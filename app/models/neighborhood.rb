class Neighborhood < ApplicationRecord
  has_many :properties, dependent: :restrict_with_error

  validates :name, presence: true, length: { maximum: 120 }, uniqueness: { scope: :city }
  validates :city, presence: true, length: { maximum: 120 }
end
