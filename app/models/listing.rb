class Listing < ApplicationRecord
  belongs_to :property

  has_one :neighborhood, through: :property

  has_many :listing_photos, dependent: :destroy
  has_many :saved_listings, dependent: :destroy
  has_many :applications,   dependent: :destroy
  has_many :reports,        dependent: :destroy

  enum :status, {
    draft: "draft",
    published: "published",
    reserved: "reserved",
    rented: "rented",
    withdrawn: "withdrawn"
  }

  scope :available_by, ->(date) { where("available_from <= ?", date) }
  scope :under_rent, ->(amount) { where("monthly_rent <= ?", amount) }
  scope :order_soonest_first, -> { order(:available_from) }
  scope :with_neighborhood, -> { includes(:property, :neighborhood) }
  scope :with_room_details, -> { includes(:listing_photos, property: [ :neighborhood, :amenities, :shared_spaces, { reviews: :user } ]) }
  scope :published_index, -> { published.with_neighborhood.order_soonest_first }

  validates :title, presence: true, length: { maximum: 150 }
  validates :status, presence: true
  validates :minimum_stay_days, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :monthly_rent, presence: true, numericality: { greater_than: 0 }
  validates :deposit, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :is_furnished, inclusion: { in: [ true, false ] }
  validates :has_private_bathroom, inclusion: { in: [ true, false ] }
  validates :available_from, presence: true

  validate  :available_from_not_in_past, if: :will_save_change_to_available_from?

  private

  def available_from_not_in_past
    return if available_from.blank?

    if available_from < Date.current
      errors.add(:available_from, "cant be in the past, choose a future date")
    end
  end
end
