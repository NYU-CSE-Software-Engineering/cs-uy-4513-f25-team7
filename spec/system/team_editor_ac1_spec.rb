# spec/system/team_editor_ac1_spec.rb
# or: spec/features/team_editor_ac1_spec.rb

require "rails_helper"

RSpec.describe "Team Editor AC1: create/edit/save a team", type: :system do
  # If you're using Devise and require authentication for TeamsController,
  # uncomment this and make sure Devise helpers are available in system specs.
  #
  # include Devise::Test::IntegrationHelpers
  #
  # let(:user) { create(:user) }
  #
  # before do
  #   sign_in user
  # end

  it "creates a valid draft team with up to 6 Pokémon" do
    visit new_team_path

    # Sanity check: we are on the Team Editor page
    expect(page).to have_content("Team Editor")

    # Set team name
    fill_in "Team Name", with: "Rain Balance"

    # Slot 1: Pelipper (matches your Cucumber step)
    within "#slot-1" do
      fill_in "Species", with: "Pelipper"
      fill_in "Item",    with: "Damp Rock"
      fill_in "Ability", with: "Drizzle"
      fill_in "Nature",  with: "Bold"

      fill_in "Move 1", with: "Hurricane"
      fill_in "Move 2", with: "Tailwind"
      fill_in "Move 3", with: "Wide Guard"
      fill_in "Move 4", with: "Protect"
    end

    # Slot 2: Ludicolo (matches your Cucumber step)
    within "#slot-2" do
      fill_in "Species", with: "Ludicolo"
      fill_in "Item",    with: "Life Orb"
      fill_in "Ability", with: "Swift Swim"
      fill_in "Nature",  with: "Modest"

      fill_in "Move 1", with: "Hydro Pump"
      fill_in "Move 2", with: "Giga Drain"
      fill_in "Move 3", with: "Ice Beam"
      fill_in "Move 4", with: "Protect"
    end

    # Slots 3–6: any valid dummy Pokémon; your Cucumber uses a generic config.
    (3..6).each do |i|
      within "#slot-#{i}" do
        fill_in "Species", with: "Pikachu"
        fill_in "Item",    with: "Focus Sash"
        fill_in "Ability", with: "Static"
        fill_in "Nature",  with: "Timid"

        fill_in "Move 1", with: "Thunderbolt"
        fill_in "Move 2", with: "Volt Switch"
        fill_in "Move 3", with: "Protect"
        fill_in "Move 4", with: "Fake Out"
      end
    end

    # Click Save
    click_button "Save"

    # UI expectations matching your Cucumber scenario/steps
    expect(page).to have_content("Saved draft: Rain Balance")
    expect(page).to have_content("Draft Owned by me")
    expect(page).to have_content("Last saved:")

    # (Optional but nice) – check the team persisted correctly in the DB
    team = Team.order(created_at: :desc).first
    expect(team.name).to eq("Rain Balance")
    expect(team.status).to eq("draft") if team.respond_to?(:status)
    expect(team.visibility).to eq("private") if team.respond_to?(:visibility)
  end
end
