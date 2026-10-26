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

  validate :listing_can_be_reported, on: :create
  validate :reviewed_at_after_report_created
  validate :review_data_matches_status

  private

  def listing_can_be_reported
    return if listing.nil? || user.nil?

    if listing.hosted_by?(user)
      errors.add(:listing, "is yours, you can't report your own listing")
    elsif !listing.visible_to?(user)
      errors.add(:listing, "is not available")
    end
  end

  def reviewed_at_after_report_created
    return if reviewed_at.blank? || created_at.blank?

    if reviewed_at < created_at
      errors.add(:reviewed_at, "date cant be set to before the date of the reports creation")
    end
  end

  def review_data_matches_status
    if pending?
      if reviewer.present? || reviewed_at.present?
        errors.add(:base, "A pending report can't have a reviewer or a review date")
      end
    else
      errors.add(:reviewer, "must be a moderator") unless reviewer&.moderator?
      errors.add(:reviewed_at, "must be set once the report is handled") if reviewed_at.blank?
    end
  end
end
