class Message < ApplicationRecord
  belongs_to :sender, class_name: "User"
  belongs_to :recipient, class_name: "User"

  validates :body, presence: true

  scope :unread, -> { where(read_at: nil) }

  def mark_read!
    return if read_at.present?
    update!(read_at: Time.current)
  end
end
