# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Species pages", type: :request do
  let(:user)        { User.create!(email: "user@example.com", password: "password") }
  let!(:dex_species) { DexSpecies.create!(name: "Pelipper", pokeapi_id: 279) }

  def sign_in(user)
    post user_session_path, params: { email: user.email, password: "password" }
  end

  describe "GET /species/:name" do
    it "renders a species show page with follower data" do
      FollowsController.seed_followers("Pelipper", count: 3)

      get species_path(name: "Pelipper")

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Pelipper")
      expect(response.body).to include("3") # follower count
    end
  end

  describe "POST /species/:name/posts" do
    it "creates a discussion post for the species" do
      sign_in(user)

      expect {
        post species_posts_path(name: "Pelipper"), params: {
          post: { title: "Rain lead", body: "Pelipper sets rain", post_type: "Thread" }
        }
      }.to change(Post, :count).by(1)

      expect(response).to redirect_to(species_path(name: "Pelipper"))
      expect(flash[:notice]).to eq("Discussion posted!")
      expect(Post.last.dex_species).to eq(dex_species)
    end

    it "rejects invalid posts and re-renders the show page" do
      sign_in(user)

      expect {
        post species_posts_path(name: "Pelipper"), params: {
          post: { title: "", body: "Missing title", post_type: "Thread" }
        }
      }.not_to change(Post, :count)

      expect(response).to have_http_status(:ok) # render :show
      expect(response.body).to include("Pelipper")
    end

    it "redirects when the species is not found" do
      sign_in(user)

      post species_posts_path(name: "Missingno"), params: {
        post: { title: "Ghost", body: "Unknown", post_type: "Thread" }
      }

      expect(response).to redirect_to(species_path(name: "Missingno"))
      expect(flash[:alert]).to eq("Species not found")
    end
  end
end

