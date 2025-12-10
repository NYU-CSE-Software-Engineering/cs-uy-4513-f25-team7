# spec/requests/reviews_spec.rb
require "rails_helper"

RSpec.describe "Reviews", type: :request do
  let(:team_owner) { User.create!(email: "owner@example.com", password: "password123", role: :user) }
  let(:reviewer) { User.create!(email: "reviewer@example.com", password: "password123", role: :user) }
  let(:moderator) { User.create!(email: "mod@example.com", password: "password123", role: :moderator) }
  let(:team) { Team.create!(name: "Test Team", user: team_owner, status: :published, visibility: :public_team) }

  def sign_in(user)
    post "/login", params: { email: user.email, password: "password123" }
  end

  describe "POST /teams/:team_id/reviews" do
    context "when logged in" do
      before { sign_in(reviewer) }

      it "creates a review successfully" do
        expect {
          post team_reviews_path(team), params: { review: { rating: 4, body: "Great team!" } }
        }.to change(Review, :count).by(1)

        expect(response).to redirect_to(team)
        follow_redirect!
        expect(response.body).to include("Review submitted successfully")
      end

      it "fails with invalid rating" do
        expect {
          post team_reviews_path(team), params: { review: { rating: 0, body: "Invalid" } }
        }.not_to change(Review, :count)

        expect(response).to redirect_to(team)
      end

      it "prevents reviewing own team" do
        sign_in(team_owner)
        
        expect {
          post team_reviews_path(team), params: { review: { rating: 5, body: "My team is great!" } }
        }.not_to change(Review, :count)
      end

      it "creates a notification for the team owner" do
        expect {
          post team_reviews_path(team), params: { review: { rating: 4, body: "Nice!" } }
        }.to change(Notification, :count).by(1)

        notification = Notification.last
        expect(notification.user).to eq(team_owner)
        expect(notification.actor).to eq(reviewer)
        expect(notification.event_type).to eq("new_review")
      end
    end

    # Note: In test mode, authenticate_user! is bypassed (returns early)
    # so we can't test the redirect behavior here. The authentication
    # guard is tested via Cucumber features instead.
  end

  describe "PATCH /teams/:team_id/reviews/:id" do
    let!(:review) { Review.create!(team: team, user: reviewer, rating: 3, body: "Original") }

    context "when logged in as the reviewer" do
      before { sign_in(reviewer) }

      it "updates the review" do
        patch team_review_path(team, review), params: { review: { rating: 5, body: "Updated!" } }
        
        expect(response).to redirect_to(team)
        review.reload
        expect(review.rating).to eq(5)
        expect(review.body).to eq("Updated!")
      end
    end

    context "when logged in as someone else" do
      let(:other_user) { User.create!(email: "other@example.com", password: "password123", role: :user) }
      before { sign_in(other_user) }

      it "does not allow editing another user's review" do
        patch team_review_path(team, review), params: { review: { rating: 1 } }
        
        expect(response).to redirect_to(team)
        review.reload
        expect(review.rating).to eq(3) # unchanged
      end
    end
  end

  describe "DELETE /teams/:team_id/reviews/:id" do
    let!(:review) { Review.create!(team: team, user: reviewer, rating: 3) }

    context "when logged in as the reviewer" do
      before { sign_in(reviewer) }

      it "deletes the review (hard delete)" do
        expect {
          delete team_review_path(team, review)
        }.to change(Review, :count).by(-1)

        expect(response).to redirect_to(team)
      end
    end

    context "when logged in as a moderator" do
      before { sign_in(moderator) }

      it "soft-deletes the review" do
        expect {
          delete team_review_path(team, review)
        }.not_to change(Review, :count)

        review.reload
        expect(review.deleted?).to be true
      end

      it "notifies the reviewer that their review was removed" do
        expect {
          delete team_review_path(team, review)
        }.to change(Notification, :count).by(1)

        notification = Notification.last
        expect(notification.user).to eq(reviewer)
        expect(notification.event_type).to eq("review_removed")
      end
    end

    context "when logged in as someone else" do
      let(:other_user) { User.create!(email: "other@example.com", password: "password123", role: :user) }
      before { sign_in(other_user) }

      it "does not allow deleting another user's review" do
        expect {
          delete team_review_path(team, review)
        }.not_to change(Review, :count)

        review.reload
        expect(review.deleted?).to be false
      end
    end
  end
end

