class SavedListing < ApplicationRecord
  belongs_to :listing
  belongs_to :user

  validates :user_id, uniqueness: { scope: :listing_id }

  validate :listing_can_be_saved, on: :create

  private

  def listing_can_be_saved
    return if listing.nil? || user.nil?

    if listing.hosted_by?(user)
      errors.add(:listing, "is yours, you can't save your own listing")
    elsif !listing.visible_to?(user)
      errors.add(:listing, "is not available")
    end
  end
end
