class Review < ApplicationRecord
  belongs_to :property
  belongs_to :user
  belongs_to :visit

  scope :recent, -> { order(created_at: :desc) }
  scope :by_rating, -> { order(:rating) }

  validates :rating, numericality: { only_integer: true, in: 1..5 }
  validates :visit_id, uniqueness: true

  validate :visit_is_completed, on: :create
  validate :review_by_seeker, on: :create
  validate :property_matches_visit_property, on: :create

  private

  def visit_is_completed
    return if visit.nil?

    unless visit.completed?
      errors.add(:visit, "must have visited the property to write the review")
    end
  end

  def review_by_seeker
    unless user_id == visit&.application&.seeker_id
      errors.add(:user, "has to be the one that visited to review")
    end
  end

  def property_matches_visit_property
    unless property_id == visit&.application&.listing&.property_id
      errors.add(:property, "has to be the same as the visited property")
    end
  end
end
