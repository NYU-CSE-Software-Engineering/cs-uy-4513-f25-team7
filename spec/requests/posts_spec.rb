require 'rails_helper'

RSpec.describe "Posts", type: :request do
  let(:user) { User.create!(email: 'test@example.com', password: 'password123') }

  describe "GET /posts" do
    it "returns http success" do
      get posts_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /posts/new" do
    context "when user is signed in" do
      before { sign_in user }

      it "returns http success" do
        get new_post_path
        expect(response).to have_http_status(:success)
      end
    end

    context "when user is not signed in" do
      it "redirects to sign in" do
        get new_post_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "POST /posts" do
    context "when user is signed in" do
      before { sign_in user }

      context "with valid parameters" do
        let(:valid_attributes) { { title: 'Test Post', body: 'Test body', post_type: 'thread' } }

        it "creates a new post" do
          expect {
            post posts_path, params: { post: valid_attributes }
          }.to change(Post, :count).by(1)
        end

        it "redirects to the post" do
          post posts_path, params: { post: valid_attributes }
          expect(response).to redirect_to(post_path(Post.last))
        end
      end

      context "with invalid parameters" do
        let(:invalid_attributes) { { title: '', body: 'Test body' } }

        it "does not create a new post" do
          expect {
            post posts_path, params: { post: invalid_attributes }
          }.not_to change(Post, :count)
        end
      end
    end
  end

  describe "GET /posts/:id" do
    let(:post_record) { Post.create!(user: user, title: 'Test', body: 'Body', post_type: 'thread') }

    it "returns http success" do
      get post_path(post_record)
      expect(response).to have_http_status(:success)
    end
  end
end
