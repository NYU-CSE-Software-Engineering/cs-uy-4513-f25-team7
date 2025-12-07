require "rails_helper"

RSpec.describe Follow, type: :model do
  let(:follower) { User.create!(email: "ash@example.com", password: "password") }
  let(:followee) { User.create!(email: "misty@example.com", password: "password") }

  it "is valid with follower and followee" do
    expect(described_class.new(follower: follower, followee: followee)).to be_valid
  end

  it "is invalid when following the same user twice" do
    described_class.create!(follower: follower, followee: followee)
    dup_follow = described_class.new(follower: follower, followee: followee)

    expect(dup_follow).not_to be_valid
    expect(dup_follow.errors[:follower_id]).to include("has already been taken")
  end

  it "is invalid when follower equals followee" do
    follow = described_class.new(follower: follower, followee: follower)

    expect(follow).not_to be_valid
    expect(follow.errors[:followee_id]).to be_present
  end
end
