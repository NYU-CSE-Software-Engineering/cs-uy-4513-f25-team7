require "rails_helper"

RSpec.describe Favorite, type: :model do
  let(:user) { User.create!(email: "fav@example.com", password: "password") }
  let(:team_owner) { User.create!(email: "owner@example.com", password: "password") }
  let(:team) { Team.create!(name: "Rain Dance", user: team_owner) }

  it "is valid with user and favoritable" do
    expect(described_class.new(user: user, favoritable: team)).to be_valid
  end

  it "enforces uniqueness per user and favoritable" do
    described_class.create!(user: user, favoritable: team)
    dup = described_class.new(user: user, favoritable: team)

    expect(dup).not_to be_valid
    expect(dup.errors[:favoritable_id]).to include("has already been favorited")
  end
end
