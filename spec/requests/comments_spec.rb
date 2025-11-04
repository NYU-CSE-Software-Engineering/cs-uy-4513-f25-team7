require 'rails_helper'

RSpec.describe "Comments", type: :request do
  let(:user) { User.create!(email: 'test@example.com', password: 'password123') }
  let(:post_record) { Post.create!(user: user, title: 'Test Post', body: 'Test Body', post_type: 'thread') }

  describe "POST /posts/:post_id/comments" do
    context "when user is signed in" do
      before { sign_in user }

      context "with valid parameters" do
        let(:valid_attributes) { { body: 'Great post!' } }

        it "creates a new comment" do
          expect {
            post post_comments_path(post_record), params: { comment: valid_attributes }
          }.to change(Comment, :count).by(1)
        end

        it "redirects to the post" do
          post post_comments_path(post_record), params: { comment: valid_attributes }
          expect(response).to redirect_to(post_path(post_record))
        end
      end

      context "with invalid parameters" do
        let(:invalid_attributes) { { body: '' } }

        it "does not create a new comment" do
          expect {
            post post_comments_path(post_record), params: { comment: invalid_attributes }
          }.not_to change(Comment, :count)
        end
      end
    end

    context "when user is not signed in" do
      it "redirects to sign in" do
        post post_comments_path(post_record), params: { comment: { body: 'Test' } }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
