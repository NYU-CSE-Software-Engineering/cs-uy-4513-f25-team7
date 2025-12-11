require "rails_helper"

RSpec.describe "Google OAuth with 2FA enabled", type: :request do
  let(:auth_hash) do
    OmniAuth::AuthHash.new(
      provider: "google_oauth2",
      uid: "google-uid-123",
      info: {
        email: "ash@poke.example",
        name: "Ash Ketchum"
      },
      credentials: {
        token: "access-token-123",
        refresh_token: "refresh-token-abc",
        expires_at: 1.hour.from_now.to_i
      }
    )
  end

  before do
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:google_oauth2] = auth_hash
  end

  it "redirects to 2FA prompt instead of signing in immediately" do
    user = User.create!(
      email: "ash@poke.example",
      password: "pikachu123",
      password_confirmation: "pikachu123",
      otp_enabled: true,
      otp_secret: ROTP::Base32.random_base32
    )

    get "/auth/google_oauth2/callback", env: { "omniauth.auth" => auth_hash }

    expect(response).to redirect_to(two_factor_verify_path)
    expect(session[:pending_user_id]).to eq(user.id)
    expect(session[:user_id]).to be_nil
  end
end
