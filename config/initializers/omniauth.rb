require "omniauth"
require "omniauth-google-oauth2"

OmniAuth.config.allowed_request_methods = %i[post get]
OmniAuth.config.silence_get_warning = true
OmniAuth.config.logger = Rails.logger
OmniAuth.config.test_mode = Rails.env.test?

Rails.application.config.middleware.use OmniAuth::Builder do
  client_id     = ENV["GOOGLE_CLIENT_ID"] || Rails.application.credentials.dig(:google_oauth, :client_id)
  client_secret = ENV["GOOGLE_CLIENT_SECRET"] || Rails.application.credentials.dig(:google_oauth, :client_secret)
  redirect_uri  = ENV["GOOGLE_OAUTH_REDIRECT_URI"]

  if client_id.blank? || client_secret.blank?
    if Rails.env.production?
      raise "Missing Google OAuth credentials. Set GOOGLE_CLIENT_ID and GOOGLE_CLIENT_SECRET."
    else
      Rails.logger.warn("Google OAuth credentials missing. Set GOOGLE_CLIENT_ID/GOOGLE_CLIENT_SECRET to enable real Google SSO.")
      client_id     = "test"
      client_secret = "test"
    end
  end

  provider :google_oauth2, client_id, client_secret,
           scope: "email,profile",
           access_type: "offline",
           prompt: "consent",
           redirect_uri: redirect_uri.presence,
           image_aspect_ratio: "square",
           image_size: 100
end
