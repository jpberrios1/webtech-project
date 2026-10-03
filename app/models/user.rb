class User < ApplicationRecord
  has_many :properties, dependent: :destroy
  has_many :saved_listings, dependent: :destroy
  has_many :saved, through: :saved_listings, source: :listing # Convinience of getting all listings saved rapidly
  has_many :applications, foreign_key: :seeker_id, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :reports, dependent: :destroy
  has_many :reviewed_reports, class_name: "Report", foreign_key: :reviewer_id, dependent: :nullify

  enum :role, { member: "member", moderator: "moderator" }

  validates :name, presence: true, length: { maximum: 120 }
  validates :email_address, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 255 }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password_digest, presence: true, length: { maximum: 255 }
  validates :phone, length: { maximum: 30 }
end
