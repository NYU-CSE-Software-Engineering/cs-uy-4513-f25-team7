require "omniauth"
require "omniauth-google-oauth2"

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, "FAKE_KEY", "FAKE_SECRET"
end

if Rails.env.test? || Rails.env.development?
  OmniAuth.config.test_mode = true
  # Capybara uses GET by default
  OmniAuth.config.allowed_request_methods = [:get, :post]
end
