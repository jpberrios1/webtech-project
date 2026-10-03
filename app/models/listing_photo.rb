class ListingPhoto < ApplicationRecord
  belongs_to :listing

  validates :url, presence: true, length: { maximum: 500 }
  validates :caption, length: { maximum: 255 }
end
