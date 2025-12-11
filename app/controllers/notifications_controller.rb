class NotificationsController < ApplicationController
  before_action :require_login

  def index
    @notifications = current_user.notifications.order(created_at: :desc).page(params[:page]).per(20)
    @unread_count = current_user.notifications.unread.count
    mark_unread_as_read!
  end

  private

  def mark_unread_as_read!
    current_user.notifications.unread.update_all(read_at: Time.current)
  end
end
