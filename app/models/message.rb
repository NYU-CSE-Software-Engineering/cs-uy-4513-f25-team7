# app/models/message.rb
class Message < ApplicationRecord
  belongs_to :sender,    class_name: "User"
  belongs_to :recipient, class_name: "User"

  attr_accessor :recipient_email

  validates :body, presence: true
  validates :recipient, presence: true

  scope :unread, -> { where(read_at: nil) }

  def mark_read!
    return unless read_at.nil?

    update!(read_at: Time.current)
  end
end
