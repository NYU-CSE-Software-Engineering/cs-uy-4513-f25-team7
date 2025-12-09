require "rails_helper"

RSpec.describe "Two-factor enrollment (invalid code)", type: :request do
  it "does not enable 2FA and shows an error when the code is wrong" do
    # Arrange: user without 2FA
    user = User.create!(
      email: "ash@poke.example",
      password: "pikachu123",
      password_confirmation: "pikachu123",
      otp_enabled: false,
      otp_secret: nil
    )

    # Simulate login
    post user_session_path, params: { email: user.email, password: "pikachu123" }
    follow_redirect!
    expect(response).to have_http_status(:ok)

    # Begin enrollment (sets otp_secret, shows QR/instructions)
    get new_two_factor_path
    expect(response).to have_http_status(:ok)
    user.reload
    expect(user.otp_secret).to be_present

    # Act: submit an invalid code
    post two_factor_path, params: { code: "000000" } # clearly wrong
    expect(response).to have_http_status(:found) # redirect back to settings

    follow_redirect!
    expect(response).to have_http_status(:ok)

    # Assert: error message and 2FA remains disabled
    expect(response.body).to include("Incorrect code. Please try again.")
    user.reload
    expect(user.otp_enabled).to be(false)
  end

  it "rejects submission if no enrollment is in progress" do
    user = User.create!(
      email: "ash@poke.example",
      password: "pikachu123",
      password_confirmation: "pikachu123",
      otp_enabled: false,
      otp_secret: nil
    )

    post user_session_path, params: { email: user.email, password: "pikachu123" }
    follow_redirect!

    # Submit without starting enrollment
    post two_factor_path, params: { code: "000000" }
    expect(response).to have_http_status(:found)
    follow_redirect!
    expect(response.body).to include("No 2FA enrollment in progress")
    user.reload
    expect(user.otp_enabled).to be(false)
  end
end
