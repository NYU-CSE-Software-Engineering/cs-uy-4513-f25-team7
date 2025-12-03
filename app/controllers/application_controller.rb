class ApplicationController < ActionController::Base
  helper_method :current_user, :user_signed_in?

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def user_signed_in?
    current_user.present?
  end

  def require_login
    unless user_signed_in?
      redirect_to new_user_session_path
    end
  end

  # Gate for moderator-only actions (Role Management page & updates)
  def require_moderator
    unless current_user&.moderator?
      # AC3: regular users must see "Not authorized"
      redirect_to root_path, alert: "Not authorized"
    end
  end

  # after “sign up”, send them home
  def after_sign_up_path_for(_user)
    root_path
  end
end
