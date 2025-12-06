class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :actor, class_name: "User"
  belongs_to :notifiable, polymorphic: true, optional: true

  scope :unread, -> { where(read_at: nil) }

  def mark_read!
    update!(read_at: Time.current)
  end

  def read?
    read_at.present?
  end
end
