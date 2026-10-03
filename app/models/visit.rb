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

  validate :scheduled_at_after_application_created

  private

  def scheduled_at_after_application_created
    return if scheduled_at.nil? || application.nil?

    if scheduled_at <= application.created_at
      errors.add(:scheduled_at, "must be after the application was created")
    end
  end
end
