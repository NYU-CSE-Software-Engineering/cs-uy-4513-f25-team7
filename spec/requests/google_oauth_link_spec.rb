require "rails_helper"

RSpec.describe "Login page", type: :request do
  it "shows a 'Sign in with Google' link" do
    get new_user_session_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Sign in with Google")
  end
end
