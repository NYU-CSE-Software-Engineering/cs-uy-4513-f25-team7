require "rails_helper"

RSpec.describe "Login with 2FA enabled", type: :request do
  it "prompts for code then rejects an invalid code and stays on prompt" do
    user = User.create!(
      email: "ash@poke.example",
      password: "pikachu123",
      password_confirmation: "pikachu123",
      otp_enabled: true,
      otp_secret: ROTP::Base32.random_base32
    )

    # 1) Submit email/password -> should redirect to 2FA prompt
    post user_session_path, params: { email: user.email, password: "pikachu123" }
    expect(response).to have_http_status(:found)
    expect(response).to redirect_to(two_factor_verify_path)

    # Explicitly request the prompt page (more reliable than follow_redirect!)
    get two_factor_verify_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Enter authentication code")

    # 2) Submit wrong code -> remain on prompt with error
    post two_factor_verify_path, params: { code: "000000" }
    # We render :prompt with status :unauthorized on invalid code
    expect(response).to have_http_status(:unauthorized)
    expect(response.body).to include("Invalid two-factor code")
    expect(response.body).to include("Enter authentication code")
  end
end
