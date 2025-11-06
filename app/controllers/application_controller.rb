class ApplicationController < ActionController::Base
  helper_method :current_user, :user_signed_in?

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def user_signed_in?
    current_user.present?
  end

  def require_login
    redirect_to new_user_session_path unless user_signed_in?
  end

  # after “sign up”, send them home
  def after_sign_up_path_for(_resource)
    root_path
  end
end
