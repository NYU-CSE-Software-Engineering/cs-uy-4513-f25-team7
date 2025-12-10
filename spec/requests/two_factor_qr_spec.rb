require "rails_helper"

RSpec.describe "Two-factor enrollment QR", type: :request do
  it "renders a real QR data URI for the provisioning URL" do
    user = User.create!(email: "qr@example.com", password: "password")
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
    allow_any_instance_of(ApplicationController).to receive(:user_signed_in?).and_return(true)

    get "/two_factor/new"

    expect(response).to be_successful
    expect(response.body).to include("data:image/png;base64")
    expect(response.body).not_to include("R0lGODlhAQABAIAAAAUEBA==") # 1x1 pixel placeholder
  end
end
