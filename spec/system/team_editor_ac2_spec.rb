# spec/system/team_editor_ac2_spec.rb

require "rails_helper"

RSpec.describe "Team Editor AC2: attempting to add a 7th Pokémon is rejected", type: :system do
  # If TeamsController requires authentication, mirror whatever you did in AC1:
  #
  # include Devise::Test::IntegrationHelpers
  # let(:user) { create(:user) }
  #
  # before do
  #   sign_in user
  # end

  it "keeps the team at 6 slots and shows a max-team-size message" do
    visit new_team_path

    # Sanity check – we're on the Team Editor page
    expect(page).to have_content("Team Editor")

    # The page should render exactly 6 Pokémon slots
    expect(page).to have_css("#team-slots .pokemon-slot-card", count: 6)
    (1..6).each do |i|
      expect(page).to have_css("#slot-#{i}[data-slot='#{i}']")
    end
    expect(page).to have_no_css("#slot-7")

    # AC2: There is an "Add Pokémon" control for trying to add a 7th
    add_button = find_button("Add Pokémon", disabled: true)
    expect(add_button).to be_disabled

    # AC2: The UI clearly communicates the max-team-size error/message
    expect(page).to have_content("A team can have at most 6 Pokémon")

    # And even after "trying", we still only have 6 slots (no new card appears)
    expect(page).to have_css("#team-slots .pokemon-slot-card", count: 6)
    expect(page).to have_no_css("#slot-7")
  end
end
