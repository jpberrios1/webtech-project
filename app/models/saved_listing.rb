class SavedListing < ApplicationRecord
  belongs_to :listing
  belongs_to :user

  validates :user_id, uniqueness: { scope: :listing_id }
end
