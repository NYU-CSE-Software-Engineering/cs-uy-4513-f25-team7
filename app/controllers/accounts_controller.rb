class AccountsController < ApplicationController
  before_action :require_login
  before_action :check_admin_setup_allowed, only: [:admin_setup, :become_admin]

  # Secret admin code - in production this should be an environment variable
  ADMIN_SECRET_CODE = ENV.fetch("ADMIN_SECRET_CODE", "pokeforum2024")

  def edit
  end

  def update
    if current_user.update(profile_params)
      redirect_to edit_user_registration_path, notice: "Profile updated successfully!"
    else
      flash.now[:alert] = current_user.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_content
    end
  end

  def admin_setup
    @no_admins = User.where(role: :admin).none?
  end

  def become_admin
    if params[:admin_code] == ADMIN_SECRET_CODE
      if current_user.update(role: :admin)
        redirect_to edit_user_registration_path, notice: "🎉 You are now an admin!"
      else
        flash.now[:alert] = current_user.errors.full_messages.to_sentence
        render :admin_setup, status: :unprocessable_content
      end
    else
      flash.now[:alert] = "Invalid admin code"
      render :admin_setup, status: :unprocessable_content
    end
  end

  private

  def profile_params
    params.permit(:username)
  end

  def check_admin_setup_allowed
    # Only allow if user is not already an admin
    if current_user.admin?
      redirect_to edit_user_registration_path, notice: "You're already an admin!"
    end
  end
end
