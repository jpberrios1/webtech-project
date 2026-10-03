class SharedSpace < ApplicationRecord
  has_many :property_shared_spaces, dependent: :destroy
  has_many :properties, through: :property_shared_spaces

  validates :name, presence: true, length: { maximum: 80 }, uniqueness: { case_sensitive: false }
end
