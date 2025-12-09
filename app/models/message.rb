class Message < ApplicationRecord
  belongs_to :sender,    class_name: "User"
  belongs_to :recipient, class_name: "User"

  attr_accessor :recipient_username


  validates :body, presence: true
  validates :recipient, presence: true


  scope :unread, -> { where(read_at: nil) }


  validate :recipient_must_exist_by_username,
           if: -> { recipient_username.present? && recipient.nil? }

  # Mark a message as read, only if it's currently unread
  def mark_read!
    return unless read_at.nil?

    update!(read_at: Time.current)
  end

  private

  def recipient_must_exist_by_username
    errors.add(:recipient_username, "must match an existing user")
  end
end
