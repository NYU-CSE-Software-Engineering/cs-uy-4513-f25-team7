# frozen_string_literal: true
require "rails_helper"

RSpec.describe "Unfollow a species", type: :system do
  before do
    driven_by(:rack_test) if respond_to?(:driven_by)
    # Reset the in-memory state before each example
    FollowsController.reset!
  end

  it "allows unfollowing from the species page and decrements the follower count" do
    # Seed in-memory follow state (no models)
    FollowsController.seed_follow("Pelipper", count: 3)

    visit species_path(name: "Pelipper")
    expect(page).to have_css('[data-test="species-page"]')

    # Initial assertions
    initial = page.find('[data-test="follower-count"]').text.scan(/\d+/).first.to_i
    expect(initial).to eq(3)
    expect(page).to have_css('[data-test="follow-button"]', text: "Unfollow")

    # Unfollow -> flips to "Follow" and count - 1
    click_button "Unfollow"
    expect(page).to have_css('[data-test="follow-button"]', text: "Follow")

    after = page.find('[data-test="follower-count"]').text.scan(/\d+/).first.to_i
    expect(after).to eq(initial - 1)
  end
end
