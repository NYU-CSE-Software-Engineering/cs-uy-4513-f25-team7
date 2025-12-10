class TwoFactorController < ApplicationController
  before_action :require_login, only: [:new, :create]
  def new
    # Ensure user has a secret for enrollment
    unless current_user.otp_secret.present?
      current_user.update!(otp_secret: ROTP::Base32.random_base32)
    end

    # Build an otpauth URI manually (works across ROTP versions)
    issuer = "PokeForum"
    label  = "#{issuer}:#{current_user.email}"
    secret = current_user.otp_secret

    require "cgi"
    require "rqrcode"
    @provisioning_uri =
      "otpauth://totp/#{CGI.escape(label)}" \
        "?secret=#{secret}&issuer=#{CGI.escape(issuer)}&algorithm=SHA1&digits=6&period=30"

    qr = RQRCode::QRCode.new(@provisioning_uri)
    @qr_data_uri = qr.as_png(size: 240, border_modules: 4).to_data_url

    render :new
  end

  def create
    code = params[:code].to_s.strip
    unless current_user&.otp_secret.present?
      redirect_to edit_user_registration_path, alert: "No 2FA enrollment in progress" and return
    end

    totp = ROTP::TOTP.new(current_user.otp_secret)
    if totp.verify(code, drift_ahead: 1, drift_behind: 1)
      current_user.update!(otp_enabled: true)
      redirect_to edit_user_registration_path, notice: "Two-factor authentication enabled"
    else
      redirect_to edit_user_registration_path, alert: "Incorrect code. Please try again."
    end
  end

  def prompt
    @pending_user = User.find_by(id: session[:pending_user_id])
    unless @pending_user&.otp_enabled
      redirect_to new_user_session_path, alert: "No pending 2FA login" and return
    end
    # Render prompt form
  end

  def verify_login
    user = User.find_by(id: session[:pending_user_id])
    unless user&.otp_enabled
      redirect_to new_user_session_path, alert: "No pending 2FA login" and return
    end

    code = params[:code].to_s.strip
    if ROTP::TOTP.new(user.otp_secret).verify(code, drift_ahead: 1, drift_behind: 1)
      session[:pending_user_id] = nil
      session[:user_id] = user.id
      redirect_to root_path, notice: "Signed in"
    else
      flash.now[:alert] = "Invalid two-factor code"
      @pending_user = user
      render :prompt, status: :unauthorized
    end
  end

end
