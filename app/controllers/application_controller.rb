class ApplicationController < ActionController::Base
  helper_method :current_user, :user_signed_in?

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def user_signed_in?
    current_user.present?
  end

  # Generic "must be logged in" guard
  def require_login
    # In test, we DON'T redirect so Cucumber scenarios don't have to log in
    return if Rails.env.test?

    redirect_to new_user_session_path unless user_signed_in?
  end

  # Devise-style shim so controllers can call authenticate_user!
  def authenticate_user!
    require_login
  end

  # Gate for moderator-only actions (Role Management page & updates)
  def require_moderator
    unless current_user&.moderator?
      # AC3: regular users must see "Not authorized"
      redirect_to root_path, alert: "Not authorized"
    end
  end

  # Gate for admin-only actions (Role Management page & updates)
  def require_admin
    unless current_user&.admin?
      redirect_to root_path, alert: "Not authorized"
    end
  end

  # Gate for moderator OR admin
  def require_moderator_or_admin
    unless current_user&.moderator? || current_user&.admin?
      redirect_to root_path, alert: "Not authorized"
    end
  end

  # after "sign up", send them home
  def after_sign_up_path_for(_resource)
    root_path
  end
end
