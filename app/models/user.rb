class User < ApplicationRecord
  require "securerandom"
  require "bcrypt"

  has_secure_password
  encrypts :google_token, deterministic: false
  encrypts :google_refresh_token, deterministic: false
  serialize :backup_code_digests, type: Array, coder: JSON

  has_many :follower_relationships, class_name: "Follow", foreign_key: :followee_id, dependent: :destroy
  has_many :followee_relationships, class_name: "Follow", foreign_key: :follower_id, dependent: :destroy
  has_many :followers, through: :follower_relationships, source: :follower
  has_many :followees, through: :followee_relationships, source: :followee

  has_many :favorites, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy

  has_many :sent_messages, class_name: "Message", foreign_key: :sender_id, dependent: :destroy
  has_many :received_messages, class_name: "Message", foreign_key: :recipient_id, dependent: :destroy
  has_many :teams, dependent: :destroy
  scope :lookup_query, ->(q) do
    term = q.to_s.strip
    return none if term.blank?

    where(
      "LOWER(username) LIKE :term OR LOWER(email) LIKE :term",
      term: "%#{term.downcase}%"
    ).order(:username, :email)
  end
  # Roles used by the moderation feature:
  #   user (default)
  #   moderator
  enum role: {
    user: 0,
    moderator: 1,
    admin: 2
  }

  before_validation :ensure_role
  before_validation :downcase_email
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :username, uniqueness: { case_sensitive: false, allow_blank: true },
                       length: { minimum: 3, maximum: 20, allow_blank: true },
                       format: { with: /\A[a-zA-Z0-9_]+\z/, message: "can only contain letters, numbers, and underscores", allow_blank: true }
  validates :role, presence: true, inclusion: { in: roles.keys }
  validates :google_uid, uniqueness: true, allow_nil: true
  validate :cannot_remove_final_moderator
  validate :enforce_single_admin

  def display_name
    username.presence || email.split('@').first
  end

  def enable_otp!(secret = ROTP::Base32.random_base32)
    update!(otp_secret: secret, otp_enabled: true)
  end

  def otp_enabled?
    !!self[:otp_enabled]
  end

  def issue_backup_codes!(count: 10)
    codes = []
    while codes.size < count
      code = format("%04d-%04d", SecureRandom.random_number(10_000), SecureRandom.random_number(10_000))
      codes << code unless codes.include?(code)
    end
    digests = codes.map { |code| BCrypt::Password.create(code).to_s }
    update!(backup_code_digests: digests)
    codes
  end

  def use_backup_code!(code)
    return false if backup_code_digests.blank?

    code = code.to_s.strip
    matched_digest = backup_code_digests.find do |digest|
      BCrypt::Password.new(digest) == code
    rescue BCrypt::Errors::InvalidHash
      false
    end

    return false unless matched_digest

    remaining = backup_code_digests - [matched_digest]
    update!(backup_code_digests: remaining)
    true
  end

  private
  def downcase_email
    self.email = email.to_s.downcase
  end

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

end
