class User < ApplicationRecord
  has_secure_password

  has_many :follower_relationships, class_name: "Follow", foreign_key: :followee_id, dependent: :destroy
  has_many :followee_relationships, class_name: "Follow", foreign_key: :follower_id, dependent: :destroy
  has_many :followers, through: :follower_relationships, source: :follower
  has_many :followees, through: :followee_relationships, source: :followee

  has_many :favorites, dependent: :destroy
  has_many :notifications, dependent: :destroy

  before_validation :ensure_role

  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :role, presence: true

  def display_name
    name.presence || email
  end

  def enable_otp!(secret = ROTP::Base32.random_base32)
    update!(otp_secret: secret, otp_enabled: true)
  end

  private

  def ensure_role
    self.role ||= "member"
  end
end
