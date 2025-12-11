require "rails_helper"

RSpec.describe "Two-factor backup codes", type: :request do
  it "allows logging in with a backup code and consumes it" do
    user = User.create!(
      email: "ash@poke.example",
      password: "pikachu123",
      password_confirmation: "pikachu123",
      otp_enabled: true,
      otp_secret: ROTP::Base32.random_base32
    )
    codes = user.issue_backup_codes!
    code = codes.first

    # Password step
    post user_session_path, params: { email: user.email, password: "pikachu123" }
    expect(response).to redirect_to(two_factor_verify_path)

    # Backup code step
    post two_factor_verify_path, params: { code: code }
    expect(response).to redirect_to(root_path)
    follow_redirect!
    expect(response.body).to include("Signed in with backup code")

    user.reload
    expect(user.backup_code_digests.size).to eq(codes.size - 1)
  end

  it "rejects reuse of a backup code" do
    user = User.create!(
      email: "ash@poke.example",
      password: "pikachu123",
      password_confirmation: "pikachu123",
      otp_enabled: true,
      otp_secret: ROTP::Base32.random_base32
    )
    codes = user.issue_backup_codes!
    code = codes.first

    # First login consumes the code
    post user_session_path, params: { email: user.email, password: "pikachu123" }
    expect(response).to redirect_to(two_factor_verify_path)
    post two_factor_verify_path, params: { code: code }
    expect(response).to redirect_to(root_path)
    follow_redirect!

    delete destroy_user_session_path

    # Second attempt with the same code should fail
    post user_session_path, params: { email: user.email, password: "pikachu123" }
    expect(response).to redirect_to(two_factor_verify_path)
    post two_factor_verify_path, params: { code: code }
    expect(response).to have_http_status(:unauthorized)
    expect(response.body).to include("Invalid two-factor code")

    user.reload
    expect(user.backup_code_digests.size).to eq(codes.size - 1)
  end
end
