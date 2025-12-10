# spec/models/profanity_filter_spec.rb
require 'rails_helper'

RSpec.describe 'ProfanityFilter' do
  let(:user) do
    User.create!(
      email: "profanity_user_#{SecureRandom.hex(4)}@example.com",
      password: "password123"
    )
  end

  describe Post do
    it 'rejects profanity in title' do
      post = Post.new(
        user: user,
        title: "This is darn rude",
        body:  "Clean body",
        post_type: "Thread"
      )

      expect(post).not_to be_valid
      expect(post.errors[:title]).to include("contains inappropriate language")
    end

    it 'rejects profanity in body' do
      post = Post.new(
        user: user,
        title: "Clean title",
        body:  "This body is darn rude",
        post_type: "Thread"
      )

      expect(post).not_to be_valid
      expect(post.errors[:body]).to include("contains inappropriate language")
    end

    it 'allows a clean post' do
      post = Post.new(
        user: user,
        title: "Friendly discussion",
        body:  "This is a nice, polite post.",
        post_type: "Thread"
      )

      expect(post).to be_valid
    end
  end

  describe Comment do
    let(:post_record) do
      Post.create!(
        user: user,
        title: "Some title",
        body:  "Some body",
        post_type: "Thread"
      )
    end

    it 'rejects profanity in body' do
      comment = Comment.new(
        post: post_record,
        user: user,
        body: "This is darn rude"
      )

      expect(comment).not_to be_valid
      expect(comment.errors[:body]).to include("contains inappropriate language")
    end

    it 'allows a clean comment' do
      comment = Comment.new(
        post: post_record,
        user: user,
        body: "This is a very nice comment."
      )

      expect(comment).to be_valid
    end
  end

  describe Message do
    let(:recipient) do
      User.create!(
        email: "recipient_#{SecureRandom.hex(4)}@example.com",
        password: "password123"
      )
    end

    it 'rejects profanity in body' do
      message = Message.new(
        sender: user,
        recipient: recipient,
        body: "This is darn rude"
      )

      expect(message).not_to be_valid
      expect(message.errors[:body]).to include("contains inappropriate language")
    end

    it 'allows a clean message' do
      message = Message.new(
        sender: user,
        recipient: recipient,
        body: "Hey, want to set up a battle later?"
      )

      expect(message).to be_valid
    end
  end
end
