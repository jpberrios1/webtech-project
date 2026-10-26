class Listing < ApplicationRecord
  PHOTO_CONTENT_TYPES = %w[image/jpeg image/png image/webp].freeze
  PHOTO_MAX_SIZE = 5.megabytes

  belongs_to :property

  has_rich_text :description
  has_rich_text :house_rules

  has_one :neighborhood, through: :property

  has_many :listing_photos, dependent: :destroy
  has_many :saved_listings, dependent: :destroy
  has_many :applications,   dependent: :destroy
  has_many :reports,        dependent: :destroy

  has_many_attached :photos do |attachable|
    attachable.variant :card, resize_to_fill: [ 400, 250 ]
    attachable.variant :large, resize_to_limit: [ 1200, 800 ]
  end

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
  scope :published_index, -> { published.with_neighborhood.with_attached_photos.order_soonest_first }

  validates :title, presence: true, length: { maximum: 150 }
  validates :status, presence: true
  validates :minimum_stay_days, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :monthly_rent, presence: true, numericality: { greater_than: 0 }
  validates :deposit, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :is_furnished, inclusion: { in: [ true, false ] }
  validates :has_private_bathroom, inclusion: { in: [ true, false ] }
  validates :available_from, presence: true

  validate  :available_from_not_in_past, if: :will_save_change_to_available_from?
  validate  :photos_are_valid_images

  def hosted_by?(user)
    user.present? && property.user_id == user.id
  end

  def visible_to?(user)
    !draft? || hosted_by?(user)
  end

  def publish
    unless draft?
      errors.add(:status, "can only publish a listing while in draft status")
      return false
    end

    if available_from < Date.current
      errors.add(:available_from, "is in the past, update it before publishing")
      return false
    end

    update(status: :published, published_at: Time.current)
  end

  def withdraw
    if rented? || withdrawn?
      errors.add(:status, "can't withdraw a listing that is already #{status}")
      return false
    end

    transaction do
      applications.where(status: [ :pending, :shortlisted, :accepted ]).each(&:reject_and_cancel_visits!)
      update!(status: :withdrawn)
    end

    true
  rescue ActiveRecord::RecordInvalid => e
    errors.add(:base, "Failed to withdraw listing: #{e.message}")
    false
  end

  def mark_as_rented
    unless reserved?
      errors.add(:status, "can only mark a listing as rented while in reserved status")
      return false
    end

    update(status: :rented)
  end

  private

  def available_from_not_in_past
    return if available_from.blank?

    if available_from < Date.current
      errors.add(:available_from, "cant be in the past, choose a future date")
    end
  end

  def photos_are_valid_images
    photos.each do |photo|
      next if photo.persisted?

      unless PHOTO_CONTENT_TYPES.include?(photo.content_type)
        errors.add(:photos, "must be JPEG, PNG or WebP images (#{photo.filename} is not)")
      end

      if photo.byte_size > PHOTO_MAX_SIZE
        errors.add(:photos, "must be #{PHOTO_MAX_SIZE / 1.megabyte} MB or smaller each " \
                            "(#{photo.filename} is #{ActiveSupport::NumberHelper.number_to_human_size(photo.byte_size)})")
      end
    end
  end
end
