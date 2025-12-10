require "rails_helper"

RSpec.describe "Google OAuth success", type: :request do
  let(:auth_hash) do
    OmniAuth::AuthHash.new(
      provider: "google_oauth2",
      uid: "google-uid-123",
      info: {
        email: "oak@pokemon.com",
        name: "Professor Oak"
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

  it "creates a new account, stores tokens securely, and signs the user in" do
    get "/auth/google_oauth2/callback", env: { "omniauth.auth" => auth_hash }

    user = User.find_by(email: "oak@pokemon.com")
    expect(user).to be_present
    expect(user.google_uid).to eq("google-uid-123")
    expect(user.google_token).to eq("access-token-123")
    expect(user.google_refresh_token).to eq("refresh-token-abc")
    expect(user.google_token_expires_at).to be_within(1.second).of(Time.at(auth_hash.credentials[:expires_at]))

    expect(session[:user_id]).to eq(user.id)
    expect(flash[:notice]).to include("Logged in with Google")

    # Ensure the raw column value is encrypted/obscured, not plain text
    raw_token = User.connection.select_value("SELECT google_token FROM users WHERE id=#{user.id}")
    raw_refresh = User.connection.select_value("SELECT google_refresh_token FROM users WHERE id=#{user.id}")
    expect(raw_token).not_to include("access-token-123")
    expect(raw_refresh).not_to include("refresh-token-abc")
  end

  it "links an existing email without overwriting the password" do
    existing = User.create!(email: "oak@pokemon.com", password: "pikachu123", password_confirmation: "pikachu123")
    original_digest = existing.password_digest

    get "/auth/google_oauth2/callback", env: { "omniauth.auth" => auth_hash }

    existing.reload
    expect(User.where(email: "oak@pokemon.com").count).to eq(1)
    expect(existing.google_uid).to eq("google-uid-123")
    expect(existing.password_digest).to eq(original_digest)
  end
end
