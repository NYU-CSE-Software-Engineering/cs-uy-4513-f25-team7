# frozen_string_literal: true
require "rails_helper"

RSpec.describe "Follow a species", type: :system do
  before do
    # Use the lightweight Rack::Test driver (no JS needed)
    driven_by(:rack_test) if respond_to?(:driven_by)

    # Reset the in-memory state used by FollowsController between examples
    FollowsController.reset!
  end

  it "allows following from the species page and increments the follower count" do
    visit species_path(name: "Pelipper")

    # Page renders without the app layout (layout false), so no sprockets issues.
    expect(page).to have_css('[data-test="species-page"]')

    # Initial count
    initial = page.find('[data-test="follower-count"]').text.scan(/\d+/).first.to_i

    # Follow -> button text flips to "Unfollow"
    expect(page).to have_css('[data-test="follow-button"]', text: "Follow")
    click_button "Follow"
    expect(page).to have_css('[data-test="follow-button"]', text: "Unfollow")

    # Count increased by 1
    after = page.find('[data-test="follower-count"]').text.scan(/\d+/).first.to_i
    expect(after).to eq(initial + 1)
  end
end
