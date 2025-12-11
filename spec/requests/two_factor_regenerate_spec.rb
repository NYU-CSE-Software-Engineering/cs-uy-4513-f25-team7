require "rails_helper"

RSpec.describe "Regenerating two-factor authentication", type: :request do
  it "replaces the secret and requires re-verification" do
    user = User.create!(
      email: "ash@poke.example",
      password: "pikachu123",
      password_confirmation: "pikachu123",
      otp_enabled: true,
      otp_secret: ROTP::Base32.random_base32
    )

    # Log in with 2FA enabled
    post user_session_path, params: { email: user.email, password: "pikachu123" }
    expect(response).to redirect_to(two_factor_verify_path)

    totp = ROTP::TOTP.new(user.otp_secret)
    post two_factor_verify_path, params: { code: totp.now }
    expect(response).to redirect_to(root_path)
    follow_redirect!

    old_secret = user.reload.otp_secret

    # Regenerate the secret from settings
    get edit_user_registration_path
    expect(response).to have_http_status(:ok)

    post reset_two_factor_path
    expect(response).to redirect_to(new_two_factor_path)
    follow_redirect!
    expect(response.body).to include("New two-factor setup generated")

    user.reload
    expect(user.otp_enabled).to be(false)
    expect(user.otp_secret).to be_present
    expect(user.otp_secret).not_to eq(old_secret)

    # Re-enable with the new secret
    new_code = ROTP::TOTP.new(user.otp_secret).now
    post two_factor_path, params: { code: new_code }
    expect(response).to redirect_to(edit_user_registration_path)
    follow_redirect!

    user.reload
    expect(user.otp_enabled).to be(true)
    expect(response.body).to include("Two-factor authentication enabled")
  end
end
