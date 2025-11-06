require "rails_helper"

RSpec.describe Identity::LockoutTracker do
  subject(:tracker) { described_class.new(max_attempts: 5, lockout_period: 15.minutes) }

  let(:email) { "may@poke.example" }

  describe "#record_failed_attempt" do
    it "returns false until the max attempts are reached, then true" do
      4.times { expect(tracker.record_failed_attempt(email)).to be false }
      expect(tracker.record_failed_attempt(email)).to be true
    end
  end
end
