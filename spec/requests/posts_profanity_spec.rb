# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Posts profanity guard", type: :request do
  let(:user) { User.create!(email: "author@example.com", password: "password") }

  def sign_in(user)
    post user_session_path, params: { email: user.email, password: "password" }
  end

  it "rejects a post with profanity in the body" do
    sign_in(user)

    expect {
      post posts_path, params: {
        post: {
          title: "Friendly title",
          body: "This body is darn rude",
          post_type: "Thread"
        }
      }
    }.not_to change(Post, :count)

    expect(response).to have_http_status(:unprocessable_entity)
    expect(response.body).to include("Body contains inappropriate language")
  end

  it "rejects a post with profanity in the title" do
    sign_in(user)

    expect {
      post posts_path, params: {
        post: {
          title: "This darn title is rude",
          body: "Clean body text",
          post_type: "Thread"
        }
      }
    }.not_to change(Post, :count)

    expect(response).to have_http_status(:unprocessable_entity)
    expect(response.body).to include("Title contains inappropriate language")
  end
end

