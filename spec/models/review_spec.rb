# spec/models/review_spec.rb
require "rails_helper"

RSpec.describe Review, type: :model do
  let(:team_owner) { User.create!(email: "owner@example.com", password: "password123", role: :user) }
  let(:reviewer) { User.create!(email: "reviewer@example.com", password: "password123", role: :user) }
  let(:team) { Team.create!(name: "Test Team", user: team_owner, status: :published, visibility: :public_team) }

  describe "validations" do
    it "is valid with a rating between 1 and 5" do
      review = Review.new(team: team, user: reviewer, rating: 4)
      expect(review).to be_valid
    end

    it "is invalid without a rating" do
      review = Review.new(team: team, user: reviewer, rating: nil)
      expect(review).not_to be_valid
      expect(review.errors[:rating]).to include("can't be blank")
    end

    it "is invalid with a rating less than 1" do
      review = Review.new(team: team, user: reviewer, rating: 0)
      expect(review).not_to be_valid
      expect(review.errors[:rating]).to include("is not included in the list")
    end

    it "is invalid with a rating greater than 5" do
      review = Review.new(team: team, user: reviewer, rating: 6)
      expect(review).not_to be_valid
      expect(review.errors[:rating]).to include("is not included in the list")
    end

    it "is invalid with a body longer than 500 characters" do
      review = Review.new(team: team, user: reviewer, rating: 5, body: "a" * 501)
      expect(review).not_to be_valid
      expect(review.errors[:body]).to include("is too long (maximum is 500 characters)")
    end

    it "is valid with an empty body" do
      review = Review.new(team: team, user: reviewer, rating: 3, body: "")
      expect(review).to be_valid
    end

    it "prevents duplicate reviews from the same user on the same team" do
      Review.create!(team: team, user: reviewer, rating: 4)
      duplicate = Review.new(team: team, user: reviewer, rating: 5)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:user_id]).to include("has already reviewed this team")
    end

    it "prevents users from reviewing their own teams" do
      review = Review.new(team: team, user: team_owner, rating: 5)
      expect(review).not_to be_valid
      expect(review.errors[:base]).to include("You cannot review your own team")
    end
  end

  describe "scopes" do
    let!(:visible_review) { Review.create!(team: team, user: reviewer, rating: 4) }
    let(:another_user) { User.create!(email: "another@example.com", password: "password123", role: :user) }
    let!(:deleted_review) { Review.create!(team: team, user: another_user, rating: 2, deleted_at: Time.current) }

    it ".visible returns only non-deleted reviews" do
      expect(Review.visible).to include(visible_review)
      expect(Review.visible).not_to include(deleted_review)
    end

    it ".by_recent orders by created_at descending" do
      older_user = User.create!(email: "older@example.com", password: "password123", role: :user)
      older_review = Review.create!(team: team, user: older_user, rating: 3, created_at: 1.day.ago)
      
      expect(Review.visible.by_recent.first).to eq(visible_review)
      expect(Review.visible.by_recent.last).to eq(older_review)
    end
  end

  describe "#soft_delete!" do
    it "sets deleted_at timestamp" do
      review = Review.create!(team: team, user: reviewer, rating: 4)
      expect(review.deleted_at).to be_nil
      
      review.soft_delete!
      
      expect(review.deleted_at).not_to be_nil
      expect(review.deleted?).to be true
    end
  end

  describe "rating calculation" do
    it "updates team average_rating when review is created" do
      expect(team.average_rating).to eq(0.0)
      
      Review.create!(team: team, user: reviewer, rating: 4)
      team.reload
      
      expect(team.average_rating).to eq(4.0)
      expect(team.reviews_count).to eq(1)
    end

    it "recalculates average when multiple reviews exist" do
      another_user = User.create!(email: "another@example.com", password: "password123", role: :user)
      
      Review.create!(team: team, user: reviewer, rating: 5)
      Review.create!(team: team, user: another_user, rating: 3)
      team.reload
      
      expect(team.average_rating).to eq(4.0)
      expect(team.reviews_count).to eq(2)
    end

    it "excludes soft-deleted reviews from average" do
      another_user = User.create!(email: "another@example.com", password: "password123", role: :user)
      
      review1 = Review.create!(team: team, user: reviewer, rating: 5)
      Review.create!(team: team, user: another_user, rating: 1)
      team.reload
      expect(team.average_rating).to eq(3.0)
      
      review1.soft_delete!
      team.reload
      
      expect(team.average_rating).to eq(1.0)
      expect(team.reviews_count).to eq(1)
    end
  end
end

