require "omniauth"
require "omniauth-google-oauth2"

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, "FAKE_KEY", "FAKE_SECRET"
end

if Rails.env.test?
  OmniAuth.config.test_mode = true
  OmniAuth.config.allowed_request_methods = [:get, :post]
elsif Rails.env.development?
  # Provide a working mock in dev so the Google button doesn’t “cancel”
  OmniAuth.config.test_mode = true
  OmniAuth.config.allowed_request_methods = [:get, :post]
  OmniAuth.config.mock_auth[:google_oauth2] ||= OmniAuth::AuthHash.new(
    provider: "google_oauth2",
    uid: "dev-uid-123",
    info: { email: "dev_google_user@example.com", name: "Dev User" },
    credentials: { token: "dev-token", refresh_token: "dev-refresh", expires_at: (Time.now + 1.hour).to_i }
  )
end
