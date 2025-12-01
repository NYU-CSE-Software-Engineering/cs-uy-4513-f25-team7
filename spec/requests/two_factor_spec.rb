require "rails_helper"

RSpec.describe "Two-factor enrollment", type: :request do
  it "enrolls and enables 2FA on valid code" do
    user = User.create!(
      email: "ash@poke.example",
      password: "pikachu123",
      password_confirmation: "pikachu123",
      otp_enabled: false
    )

    # simulate login (since we roll our own auth)
    post user_session_path, params: { email: user.email, password: "pikachu123" }
    follow_redirect!
    expect(response).to have_http_status(:ok)

    # start enrollment
    get new_two_factor_path
    expect(response).to have_http_status(:ok)
    user.reload
    expect(user.otp_secret).to be_present

    # verify
    code = ROTP::TOTP.new(user.otp_secret).now
    post two_factor_path, params: { code: code }
    follow_redirect!
    expect(response.body).to include("Two-factor authentication enabled")

    user.reload
    expect(user.otp_enabled).to be true
  end
end
