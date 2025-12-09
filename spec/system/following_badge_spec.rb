require "rails_helper"

RSpec.describe "Following badge on species index", type: :system do
  before do
    driven_by(:rack_test) if respond_to?(:driven_by)
    FollowsController.reset!
  end

  it 'shows a "Following" badge next to a species I follow' do
    # Seed that we follow Pelipper
    FollowsController.seed_follow("Pelipper", count: 1)

    # "Search" for Pelipper (index reads ?q=)
    visit species_index_path(q: "Pelipper")

    # There should be a row containing Pelipper and a Following badge next to it
    row = page.find('[data-test="species-row"]', text: "Pelipper")
    within(row) do
      expect(page).to have_css('[data-test="following-badge"]', text: "Following")
    end
  end

  it 'does not show a badge for a species we do not follow' do
    # Not following Iron Hands
    visit species_index_path(q: "Iron Hands")
    row = page.find('[data-test="species-row"]', text: "Iron Hands")
    within(row) do
      expect(page).not_to have_css('[data-test="following-badge"]')
    end
  end
end
