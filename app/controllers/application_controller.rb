class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def current_user
    # Simple stub user for now, until you implement real auth
    @current_user ||= User.first_or_create!(email: "test@example.com")
  end
  helper_method :current_user
end
