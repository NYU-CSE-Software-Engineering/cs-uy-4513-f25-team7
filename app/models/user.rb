class User < ApplicationRecord
  has_secure_password

  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  # Roles used by the moderation feature:
  #   user (default)
  #   moderator
  enum role: {
    user: "user",
    moderator: "moderator"
  }

  before_validation :ensure_role

  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :role, presence: true, inclusion: { in: roles.keys }
  validate :cannot_remove_final_moderator

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
end
