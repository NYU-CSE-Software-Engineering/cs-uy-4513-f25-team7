class TwoFactorController < ApplicationController
  before_action :require_login

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
    @provisioning_uri =
      "otpauth://totp/#{CGI.escape(label)}" \
        "?secret=#{secret}&issuer=#{CGI.escape(issuer)}&algorithm=SHA1&digits=6&period=30"

    render :new
  end

  def create
    code = params[:code].to_s.strip
    unless current_user.otp_secret.present?
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
end
