class Application < ApplicationRecord
  belongs_to :listing
  belongs_to :seeker, class_name: "User"

  has_many :visits, dependent: :destroy

 attr_reader :rejected_applications

  enum :status, {
    pending: "pending",
    shortlisted: "shortlisted",
    accepted: "accepted",
    rejected: "rejected",
    withdrawn: "withdrawn"
  }

  scope :pending_answer, -> { pending.order(:desired_move_in_date) }

  validates :seeker_id, uniqueness: { scope: :listing_id, message: "has already applied to this listing" }
  validates :message, presence: true
  validates :desired_move_in_date, presence: true
  validates :length_of_stay_days, presence: true, numericality: { only_integer: true, greater_than: 0 }

  validate  :desired_move_in_date_not_in_past, if: :will_save_change_to_desired_move_in_date?
  validate  :seeker_is_not_host, on: :create
  validate  :listing_is_published, on: :create
  validate  :only_one_accepted_application

  def accept
    unless pending? || shortlisted?
      errors.add(:status, "can only accept an application while in pending or shortlisted status")
      return false
    end

    unless listing.published?
      errors.add(:listing, "must be published to accept an application")
      return false
    end

    transaction do
      update!(status: :accepted)
      @rejected_applications = listing.applications.where(status: [ :pending, :shortlisted ]).where.not(id: id).to_a
      @rejected_applications.each do |app|
        app.update!(status: :rejected)
        app.cancel_open_visits!
      end
      listing.update!(status: :reserved)
    end

    true

  rescue ActiveRecord::RecordInvalid => e
    errors.add(:base, "Failed to accept application: #{e.message}")
    false
  end

  def cancel_open_visits!
    visits.where(status: [ :proposed, :confirmed ]).each do |visit|
      visit.update!(status: :cancelled)
    end
  end

  private

  def desired_move_in_date_not_in_past
    return if desired_move_in_date.blank?

    if desired_move_in_date < Date.current
      errors.add(:desired_move_in_date, "cant be in the past, choose a future date")
    end
  end

  def seeker_is_not_host
    return if seeker_id.blank? || listing.blank?

    if listing.property.user_id == seeker_id
      errors.add(:seeker, "cant be the host of the property")
    end
  end

  def listing_is_published
    return if listing.nil?

    if !(listing.published?)
      errors.add(:listing, "must be published for seekers to apply")
    end
  end

  def only_one_accepted_application
    return unless accepted?

    if Application.accepted.where(listing_id: listing_id).where.not(id: id).exists?
      errors.add(:base, "This listing already has an accepted application")
    end
  end
end
