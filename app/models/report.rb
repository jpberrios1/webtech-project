class Report < ApplicationRecord
  belongs_to :user
  belongs_to :listing
  belongs_to :reviewer, class_name: "User", optional: true

  enum :reason, {
    fraudulent: "fraudulent",
    misleading: "misleading",
    offensive: "offensive",
    other: "other"
  }

  enum :status, {
    pending: "pending",
    reviewed: "reviewed",
    dismissed: "dismissed",
    actioned: "actioned"
  }

  validate :reviewed_at_after_report_created

  private

  def reviewed_at_after_report_created
    return if reviewed_at.blank? || created_at.blank?

    if reviewed_at < created_at
      errors.add(:reviewed_at, "date cant be set to before the date of the reports creation")
    end
  end
end
