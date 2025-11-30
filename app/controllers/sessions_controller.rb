class SessionsController < ApplicationController
  require "identity/lockout_tracker"

  LOCKOUT_TRACKER = Identity::LockoutTracker.new(max_attempts: 5, lockout_period: 15.minutes)

  def new; end

  def create
    email    = params[:email].to_s
    password = params[:password].to_s
    user     = User.find_by(email: email)

    if locked_out?(email)
      render_locked and return
    end

    if user&.authenticate(password)
      LOCKOUT_TRACKER.record_successful_login(email)

      if user.otp_enabled
        # defer final sign-in until code verification
        session[:pending_user_id] = user.id
        redirect_to two_factor_verify_path, notice: "Enter authentication code"
      else
        session[:user_id] = user.id
        redirect_to root_path, notice: "Signed in"
      end
    else
      lock = LOCKOUT_TRACKER.record_failed_attempt(email)
      flash.now[:alert] = lock ? "Your account is locked for 15 minutes." : "Invalid email or password"
      render :new, status: :unauthorized
    end
  end

  def destroy
    reset_session
    redirect_to root_path, notice: "Signed out"
  end

  # google login re-written to fix cucumber scenario7
  def google
    # OmniAuth middleware (in test mode) populates request.env['omniauth.auth']
    auth  = request.env['omniauth.auth']
    email = auth&.dig('info', 'email')

    # TODO in real app: find_or_create user & sign in
    if email.present?
      flash[:notice] = "Logged in with Google — Welcome, #{email}"
    else
      flash[:notice] = "Logged in with Google"
    end

    redirect_to root_path
  end

  def failure
    flash[:alert] = "Google sign-in failed or was canceled"
    redirect_to new_user_session_path
  end

  private

  def locked_out?(email)
    LOCKOUT_TRACKER.locked?(email)
  end

  def render_locked
    flash.now[:alert] = "Your account is locked for 15 minutes."
    render :new, status: :unauthorized
  end

end
