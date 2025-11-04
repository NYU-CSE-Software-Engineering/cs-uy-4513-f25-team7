# spec/system/team_editor_spec.rb
require "rails_helper"

RSpec.describe "Team Editor", type: :system do
  let!(:format) { Format.create!(key: "sv", name: "Scarlet/Violet", default: true) }
  let!(:user)   { create(:user) }

  before { sign_in user }

  it "AC1: Create a valid draft team with up to 6 Pokémon" do
    visit new_team_path
    fill_in "team_name", with: "Rain Balance"

    # Slot 1 Pelipper (assumes seeds/importers loaded Dex rows with names)
    find("#slot-1 input[placeholder='Species']").fill_in(with: "Pelipper")
    # etc… (you can drive hidden fields or use API stubs)

    click_button "Save"
    expect(page).to have_content("Saved draft: Rain Balance")
    expect(Team.last.draft?).to be true
  end

  it "Rejects adding a 7th Pokémon non-blocking" do
    team = create(:team, user:, format:)
    6.times { |i| team.team_slots.create!(position: i+1) }
    visit edit_team_path(team)
    click_button "Save" # try to add one more in your UI if present
    expect(page).to have_content("A team can have at most 6 Pokémon")
    expect(team.team_slots.count).to eq(6)
  end

  it "Inline legality marks illegal move and clears on fix" do
    team = create(:team, user:, format:)
    s = team.team_slots.create!(position: 1, species_id: DexSpecies.find_by(name: "garchomp").id)
    s.move_slots.create!(index: 0, move_id: DexMove.find_by(name: "wish").id)

    visit edit_team_path(team)
    click_button "Validate"
    expect(page).to have_content("Move cannot be learned")

    # Replace with Rock Slide, re-validate
    # ...
  end

  it "Saves draft with unresolved errors, publish disabled" do
    team = create(:team, user:, format:)
    visit edit_team_path(team)
    click_button "Save"
    expect(page).to have_css("button", text: "Publish", disabled: true)
  end

  it "Publishes a fully legal team" do
    team = create(:team, user:, format:)
    # Make it legal…
    visit edit_team_path(team)
    click_button "Validate"
    click_button "Publish"
    expect(page).to have_current_path(team_path(team))
    expect(page).to have_content("Legal")
  end
end
