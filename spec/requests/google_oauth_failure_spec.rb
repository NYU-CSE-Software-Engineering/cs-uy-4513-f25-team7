require "rails_helper"

RSpec.describe "Google OAuth failure", type: :request do
  before do
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:google_oauth2] = :invalid_credentials
  end

  it "shows an error and stays on login page" do
    # simulate Google redirect to /auth/failure
    get "/auth/failure?strategy=google_oauth2&messages=access_denied"

    follow_redirect!

    expect(response.body).to include("Google sign-in failed or was canceled")
    # stay on login page (new session)
    expect(response.body).to include("Login")
  end
end
