# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Accounts", type: :request do
  let(:user)  { User.create!(email: "user@example.com",  password: "password", role: :user) }
  let(:admin) { User.create!(email: "admin@example.com", password: "password", role: :admin) }

  def sign_in(user)
    post user_session_path, params: { email: user.email, password: "password" }
  end

  describe "PATCH /settings" do
    it "updates the username for the current user" do
      sign_in(user)

      patch update_profile_path, params: { username: "Ash" }

      expect(response).to redirect_to(edit_user_registration_path)
      expect(user.reload.username).to eq("Ash")
      expect(flash[:notice]).to eq("Profile updated successfully!")
    end
  end

  describe "GET /admin/setup" do
    it "redirects admins away from setup" do
      sign_in(admin)

      get admin_setup_path

      expect(response).to redirect_to(edit_user_registration_path)
      expect(flash[:notice]).to eq("You're already an admin!")
    end
  end

  describe "POST /admin/setup" do
    it "promotes the current user to admin with the correct code" do
      sign_in(user)

      post become_admin_path, params: { admin_code: AccountsController::ADMIN_SECRET_CODE }

      expect(response).to redirect_to(edit_user_registration_path)
      expect(user.reload.admin?).to be true
      expect(flash[:notice]).to include("You are now an admin")
    end

    it "rejects an invalid admin code" do
      sign_in(user)

      post become_admin_path, params: { admin_code: "wrong" }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(flash[:alert]).to eq("Invalid admin code")
      expect(user.reload.admin?).to be false
    end
  end
end

