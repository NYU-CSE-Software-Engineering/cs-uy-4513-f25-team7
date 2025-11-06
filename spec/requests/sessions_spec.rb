require "rails_helper"

RSpec.describe "Sessions", type: :request do
  describe "POST /login" do
    it "logs in a user without 2FA and shows the greeting" do
      User.create!(
        email: "gary@poke.example",
        password: "eevee123",
        password_confirmation: "eevee123",
        otp_enabled: false
      )

      post user_session_path, params: { email: "gary@poke.example", password: "eevee123" }
      expect(response).to have_http_status(:found) # redirect

      follow_redirect!
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Hello, gary@poke.example")
    end

    it "renders errors for bad credentials" do
      post user_session_path, params: { email: "nope@example.com", password: "wrong" }
      expect(response).to have_http_status(:unauthorized)
      expect(response.body).to include("Invalid email or password")
    end
  end
end
