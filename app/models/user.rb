class User < ApplicationRecord
  has_secure_password

  before_validation :ensure_role

  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :role, presence: true

  def enable_otp!(secret = ROTP::Base32.random_base32)
    update!(otp_secret: secret, otp_enabled: true)
  end

  private

  def ensure_role
    self.role ||= "member"
  end
end
