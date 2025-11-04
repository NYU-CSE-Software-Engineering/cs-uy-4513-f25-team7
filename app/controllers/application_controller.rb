# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  before_action :authenticate_user!, unless: :devise_controller?

  def after_sign_in_path_for(_resource)
    authenticated_root_path # → teams#index
  end
end
