module ApplicationHelper
  # Returns the count of unread notifications for the current user
  def unread_notifications_count
    return 0 unless user_signed_in?
    current_user.notifications.unread.count
  end

  # Returns true if there are any unread notifications
  def has_unread_notifications?
    unread_notifications_count > 0
  end
end
