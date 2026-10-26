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
  validate  :stay_meets_minimum, if: :will_save_change_to_length_of_stay_days?
  validate  :desired_move_in_date_after_availability, if: :will_save_change_to_desired_move_in_date?

  def cancel_open_visits!
    visits.where(status: [ :proposed, :confirmed ]).each do |visit|
      visit.update!(status: :cancelled)
    end
  end

  def reject_and_cancel_visits!
    update!(status: :rejected)
    cancel_open_visits!
  end

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
      listing.lock!
      update!(status: :accepted)
      @rejected_applications = listing.applications.where(status: [ :pending, :shortlisted ]).where.not(id: id).to_a
      @rejected_applications.each(&:reject_and_cancel_visits!)
      listing.update!(status: :reserved)
    end

    true

  rescue ActiveRecord::RecordInvalid => e
    errors.add(:base, "Failed to accept application: #{e.message}")
    false
  end

  def shortlist
    unless pending?
      errors.add(:status, "can only shortlist an application while in pending status")
      return false
    end

    unless listing.published?
      errors.add(:listing, "must be published to shortlist an application")
      return false
    end

    update(status: :shortlisted)
  end

  def reject
    if accepted?
      if listing.withdraw
        reload
        return true
      end

      errors.add(:base, "Failed to reject application: #{listing.errors.full_messages.to_sentence}")
      return false
    end

    unless pending? || shortlisted?
      errors.add(:status, "can only reject an application while in pending, shortlisted or accepted status")
      return false
    end

    transaction { reject_and_cancel_visits! }
    true

  rescue ActiveRecord::RecordInvalid => e
    errors.add(:base, "Failed to reject application: #{e.message}")
    false
  end

  def withdraw
    unless pending? || shortlisted?
      errors.add(:status, "can only withdraw an application while in pending or shortlisted status")
      return false
    end

    transaction do
      update!(status: :withdrawn)
      cancel_open_visits!
    end

    true

  rescue ActiveRecord::RecordInvalid => e
    errors.add(:base, "Failed to withdraw application: #{e.message}")
    false
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

  def stay_meets_minimum
    return if listing.nil? || length_of_stay_days.blank? || listing.minimum_stay_days.blank?

    if length_of_stay_days < listing.minimum_stay_days
      errors.add(:length_of_stay_days, "must be at least #{listing.minimum_stay_days} days for this listing")
    end
  end

  def desired_move_in_date_after_availability
    return if listing.nil? || desired_move_in_date.blank?

    if desired_move_in_date < listing.available_from
      errors.add(:desired_move_in_date, "can't be before the room is available (#{listing.available_from})")
    end
  end
end
