require "rails_helper"

RSpec.describe "Species follower count", type: :system do
  before do
    driven_by(:rack_test) if respond_to?(:driven_by)
    FollowsController.reset!
  end

  it "shows the follower count on the species page" do
    # Seed 3 followers for Iron Hands (no follow state for current user)
    FollowsController.seed_followers("Iron Hands", 3)

    visit species_path(name: "Iron Hands")
    expect(page).to have_css('[data-test="species-page"]')

    # Assert the follower count is exactly 3
    text = page.find('[data-test="follower-count"]').text
    count = text.scan(/\d+/).first.to_i
    expect(count).to eq(3)
  end
end
