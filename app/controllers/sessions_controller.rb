class SessionsController < ApplicationController
  def new; end

  def create
    user = User.find_by(email: params[:email])

    if user&.authenticate(params[:password])
      if user.otp_enabled
        # defer final sign-in until code verification
        session[:pending_user_id] = user.id
        redirect_to two_factor_verify_path, notice: "Enter authentication code"
      else
        session[:user_id] = user.id
        redirect_to root_path, notice: "Signed in"
      end
    else
      flash.now[:alert] = "Invalid email or password"
      render :new, status: :unauthorized
    end
  end

  def destroy
    reset_session
    redirect_to root_path, notice: "Signed out"
  end
end
