require "rails_helper"

RSpec.describe User, type: :model do
  it "is invalid without an email" do
    user = User.new(password: "secret", password_confirmation: "secret")
    expect(user).not_to be_valid
    expect(user.errors[:email]).to include("can't be blank")
  end
end
