require "rails_helper"

RSpec.describe User, type: :model do
  it "is invalid without an email" do
    user = User.new(password: "secret", password_confirmation: "secret")
    expect(user).not_to be_valid
    expect(user.errors[:email]).to include("can't be blank")
  end

  it "does not allow duplicate emails" do
    User.create!(
      email: "brock@poke.example",
      password: "onyx123",
      password_confirmation: "onyx123"
    )

    user2 = User.new(
      email: "brock@poke.example",
      password: "differentpass",
      password_confirmation: "differentpass"
    )

    expect(user2).not_to be_valid
    expect(user2.errors[:email]).to include("has already been taken")
  end
end
