# frozen_string_literal: true

require "rails_helper"

RSpec.describe FeedController, type: :controller do
  before do
    FakePostStore.reset!
    FollowsController.reset!
  end

  describe "GET #index with fake store data" do
    it "orders followed species posts ahead of others" do
      FollowsController.seed_follow("Pelipper")
      FakePostStore.add(title: "Followed species post", species: "Pelipper")
      FakePostStore.add(title: "Other species post", species: "Charmander")

      get :index

      titles = assigns(:ordered_posts).map(&:title)
      expect(titles.first).to eq("Followed species post")
      expect(titles.last).to eq("Other species post")
    end
  end

  describe "GET #index with DB-backed feed" do
    let(:user)   { User.create!(email: "me@example.com",     password: "password") }
    let(:friend) { User.create!(email: "friend@example.com", password: "password") }
    let(:other)  { User.create!(email: "other@example.com",  password: "password") }

    before do
      session[:user_id] = user.id
      FakePostStore.reset!
      FollowsController.reset!
    end

    it "includes followed users and prioritizes own posts with other comments" do
      friend_post = Post.create!(user: friend, title: "Friend post", body: "From friend", post_type: "Thread", created_at: 2.hours.ago)

      own_post = Post.create!(user: user, title: "My post", body: "Original body", post_type: "Thread", created_at: 1.hour.ago)
      Comment.create!(post: own_post, user: other, body: "Comment from other", created_at: Time.current + 5.seconds)

      get :index

      ordered = assigns(:ordered_posts)
      expect(ordered).to include(friend_post, own_post)
      expect(ordered.first).to eq(own_post) # newest activity from another user
    end

    it "returns an empty ordered list when there are no posts" do
      get :index
      expect(assigns(:ordered_posts)).to be_empty
    end
  end
end

