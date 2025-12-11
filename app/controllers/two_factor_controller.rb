class TwoFactorController < ApplicationController
  before_action :require_login, only: [:new, :create, :reset, :recovery_codes]
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
      backup_codes = current_user.issue_backup_codes!
      session[:backup_codes] = backup_codes
      redirect_to two_factor_recovery_codes_path, notice: "Two-factor authentication enabled"
    else
      redirect_to edit_user_registration_path, alert: "Incorrect code. Please try again."
    end
  end

  def reset
    unless current_user&.otp_enabled?
      redirect_to edit_user_registration_path, alert: "Two-factor authentication is not enabled" and return
    end

    current_user.update!(otp_secret: ROTP::Base32.random_base32, otp_enabled: false, backup_code_digests: [])
    session.delete(:backup_codes)
    redirect_to new_two_factor_path, notice: "New two-factor setup generated. Scan the QR code to re-enable 2FA."
  end

  def recovery_codes
    @backup_codes = session.delete(:backup_codes)
    unless @backup_codes.present?
      redirect_to edit_user_registration_path, alert: "No backup codes to display" and return
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
    totp = user.otp_secret.present? ? ROTP::TOTP.new(user.otp_secret) : nil
    if totp&.verify(code, drift_ahead: 1, drift_behind: 1)
      session[:pending_user_id] = nil
      session[:user_id] = user.id
      redirect_to root_path, notice: "Signed in"
    elsif user.use_backup_code!(code)
      session[:pending_user_id] = nil
      session[:user_id] = user.id
      redirect_to root_path, notice: "Signed in with backup code"
    else
      flash.now[:alert] = "Invalid two-factor code"
      @pending_user = user
      render :prompt, status: :unauthorized
    end
  end

end
