require "rails_helper"

RSpec.describe "Social graph notifications", type: :request do
  def sign_in(user)
    post user_session_path, params: { email: user.email, password: "password" }
  end

  describe "follows" do
    let(:user) { User.create!(email: "me@example.com", password: "password") }
    let(:other) { User.create!(email: "misty@example.com", password: "password") }

    it "requires authentication" do
      post user_follow_path(other)
      expect(response).to redirect_to(new_user_session_path)
      expect(flash[:alert]).to eq("Please sign in to continue")
    end

    it "creates a follow and notification when signed in" do
      sign_in(user)
      expect {
        post user_follow_path(other)
      }.to change(Follow, :count).by(1)
         .and change(Notification, :count).by(1)
      expect(response).to redirect_to(user_path(other))
      followee_notification = Notification.last
      expect(followee_notification.user).to eq(other)
      expect(followee_notification.actor).to eq(user)
      expect(followee_notification.event_type).to eq("follow_created")
    end

    it "prevents duplicate follows" do
      sign_in(user)
      Follow.create!(follower: user, followee: other)

      expect {
        post user_follow_path(other)
      }.not_to change(Follow, :count)
      expect(flash[:alert]).to eq("Already following")
    end
  end

  describe "favorites" do
    let(:user) { User.create!(email: "fav@example.com", password: "password") }
    let(:owner) { User.create!(email: "owner@example.com", password: "password") }
    let(:team) { Team.create!(title: "Rain Dance", user: owner) }

    it "requires authentication" do
      post favorites_path, params: { favoritable_type: "Team", favoritable_id: team.id }
      expect(response).to redirect_to(new_user_session_path)
      expect(flash[:alert]).to eq("Please sign in to continue")
    end

    it "creates a favorite and notifies the owner" do
      sign_in(user)
      expect {
        post favorites_path, params: { favoritable_type: "Team", favoritable_id: team.id }
      }.to change(Favorite, :count).by(1)
         .and change(Notification, :count).by(1)
      expect(response).to redirect_to(team_path(team))
      notification = Notification.last
      expect(notification.user).to eq(owner)
      expect(notification.actor).to eq(user)
      expect(notification.event_type).to eq("favorite_created")
    end

    it "prevents duplicate favorites" do
      sign_in(user)
      Favorite.create!(user: user, favoritable: team)

      expect {
        post favorites_path, params: { favoritable_type: "Team", favoritable_id: team.id }
      }.not_to change(Favorite, :count)
      expect(flash[:alert]).to eq("Already favorited")
    end
  end
end
