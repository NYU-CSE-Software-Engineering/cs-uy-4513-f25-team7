class SessionsController < ApplicationController
  require "identity/lockout_tracker"
  require "securerandom"

  LOCKOUT_TRACKER = Identity::LockoutTracker.new(max_attempts: 5, lockout_period: 15.minutes)

  def new; end

  def create
    email    = params[:email].to_s.downcase
    password = params[:password].to_s
    user     = User.find_by(email: email)

    return render_locked if LOCKOUT_TRACKER.locked?(email)

    if user&.authenticate(password)
      LOCKOUT_TRACKER.record_successful_login(email)

      if user.otp_enabled
        session[:pending_user_id] = user.id
        redirect_to two_factor_verify_path, notice: "Enter authentication code"
      else
        session[:user_id] = user.id
        redirect_to root_path, notice: "Signed in"
      end
    else
      locked = LOCKOUT_TRACKER.record_failed_attempt(email)
      flash.now[:alert] = locked ? "Your account is locked for 15 minutes." : "Invalid email or password"
      render :new, status: :unauthorized
    end
  end

  def destroy
    reset_session
    redirect_to root_path, notice: "Signed out"
  end

  def google
    auth = request.env["omniauth.auth"]
    unless auth
      flash[:alert] = "Google sign-in failed or was canceled"
      return redirect_to new_user_session_path
    end

    email = auth.dig("info", "email").to_s.downcase
    uid   = auth.dig("uid")

    unless email.present?
      flash[:alert] = "Google sign-in failed or was canceled"
      return redirect_to new_user_session_path
    end

    user = User.find_or_initialize_by(email: email)
    user.password = SecureRandom.hex(16) if user.new_record?

    creds = auth["credentials"] || {}
    user.google_uid = uid
    user.google_token = creds["token"] if creds["token"].present?
    user.google_refresh_token = creds["refresh_token"] if creds["refresh_token"].present?
    user.google_token_expires_at = Time.at(creds["expires_at"]) if creds["expires_at"]
    user.save!

    reset_session
    if user.otp_enabled?
      session[:pending_user_id] = user.id
      flash[:notice] = "Enter authentication code"
      redirect_to two_factor_verify_path
    else
      session[:user_id] = user.id
      flash[:notice] = "Logged in with Google — Welcome, #{email}"
      redirect_to root_path
    end
  end

  def failure
    flash[:alert] = "Google sign-in failed or was canceled"
    redirect_to new_user_session_path
  end

  private

  def render_locked
    flash.now[:alert] = "Your account is locked for 15 minutes."
    render :new, status: :unauthorized
  end
end
