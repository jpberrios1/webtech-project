class Visit < ApplicationRecord
  belongs_to :application

  has_one :review, dependent: :destroy

  enum :status, {
    proposed: "proposed",
    confirmed: "confirmed",
    cancelled: "cancelled",
    completed: "completed"
  }

  validates :scheduled_at, presence: true

  validate :scheduled_at_not_in_past, if: :will_save_change_to_scheduled_at?
  validate :application_is_shortlisted, on: :create

  def confirm
    unless proposed?
      errors.add(:status, "can only confirm a visit while in proposed status")
      return false
    end

    update(status: :confirmed)
  end

  def cancel
    unless proposed? || confirmed?
      errors.add(:status, "can only cancel a visit while proposed or confirmed")
      return false
    end

    update(status: :cancelled)
  end

  # Only a confirmed visit that already took place can be completed.
  def complete
    unless confirmed?
      errors.add(:status, "can only complete a visit after it was confirmed")
      return false
    end

    if scheduled_at > Time.current
      errors.add(:scheduled_at, "hasn't happened yet, a visit can only be completed after it takes place")
      return false
    end

    update(status: :completed)
  end

  def reschedule(new_scheduled_at)
    unless proposed? || confirmed?
      errors.add(:status, "can only reschedule a visit while proposed or confirmed")
      return false
    end

    new_visit = nil
    transaction do
      update!(status: :cancelled)
      new_visit = application.visits.create!(scheduled_at: new_scheduled_at)
    end

    new_visit

  rescue ActiveRecord::RecordInvalid => e
    # The error belongs to the new visit (e.g. "cant be in the past"): copy it here
    # so the form for this visit can show it.
    errors.merge!(e.record.errors) unless e.record.equal?(self)
    false
  end

  private

  def scheduled_at_not_in_past
    return if scheduled_at.blank?

    if scheduled_at < Time.current
      errors.add(:scheduled_at, "cant be in the past, choose a future date")
    end
  end

  def application_is_shortlisted
    return if application.nil?

    unless application.shortlisted?
      errors.add(:application, "must be shortlisted to propose a visit")
    end
  end
end
