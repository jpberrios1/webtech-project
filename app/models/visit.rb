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

  private

  def scheduled_at_not_in_past
    return if scheduled_at.blank?

    if scheduled_at < Time.current
      errors.add(:scheduled_at, "cant be in the past, choose a future date")
    end
  end
end
