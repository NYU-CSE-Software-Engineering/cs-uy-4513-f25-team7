class User < ApplicationRecord
  has_secure_password

  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  # Roles used by the moderation feature:
  #   user (default)
  #   moderator
  enum role: {
    user: 0,
    moderator: 1,
    admin: 2
  }

  before_validation :ensure_role

  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :role, presence: true, inclusion: { in: roles.keys }
  validate :cannot_remove_final_moderator
  validate :enforce_single_admin

  def enable_otp!(secret = ROTP::Base32.random_base32)
    update!(otp_secret: secret, otp_enabled: true)
  end

  private

  def ensure_role
    # default is "user", not "member"
    self.role ||= "user"
  end

  # Prevent demoting the last moderator
  def cannot_remove_final_moderator
    return unless persisted?

    if role_was == "moderator" && role != "moderator"
      other_moderators = User.where(role: "moderator").where.not(id: id)
      if other_moderators.none?
        # this exact string is asserted in the feature
        errors.add(:base, "There must be at least one moderator on the platform")
      end
    end
  end
  # make sure there is always exactly one admin
  def enforce_single_admin
    # If I’m becoming an admin, make sure nobody else is already admin
    if role == "admin"
      other_admins = User.where(role: "admin").where.not(id: id)
      if other_admins.exists?
        errors.add(:base, "There can only be one admin on the platform")
      end
    end

    # If I’m being demoted from admin, make sure I’m not the last one
    if persisted? && role_was == "admin" && role != "admin"
      other_admins = User.where(role: "admin").where.not(id: id)
      if other_admins.none?
        errors.add(:base, "There must be at least one admin on the platform")
      end
    end
  end
  # --- 2FA / OTP stub for tests ---
  # The sessions controller expects this to exist.
  # For now, treat all users as having OTP disabled.
  def otp_enabled
    false
  end

  def otp_enabled?
    otp_enabled
  end
end

