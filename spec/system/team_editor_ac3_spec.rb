# spec/system/team_editor_ac3_spec.rb

require "rails_helper"

RSpec.describe "Team Editor AC3: inline legality validation marks illegal selections",
               type: :system do
  it "flags an illegal move for Garchomp, shows an error on Moves, and marks the slot as Illegal" do
    visit new_team_path

    expect(page).to have_content("Team Editor")

    fill_in "Team Name", with: "Sand Offense"

    within "#slot-1" do
      fill_in "Species", with: "Garchomp"
      fill_in "Item",    with: "Choice Band"
      fill_in "Ability", with: "Rough Skin"
      fill_in "Nature",  with: "Jolly"

      fill_in "HP EVs",  with: "0"
      fill_in "Atk EVs", with: "252"
      fill_in "Def EVs", with: "4"
      fill_in "SpA EVs", with: "0"
      fill_in "SpD EVs", with: "0"
      fill_in "Spe EVs", with: "252"

      fill_in "HP IVs",  with: "31"
      fill_in "Atk IVs", with: "31"
      fill_in "Def IVs", with: "31"
      fill_in "SpA IVs", with: "31"
      fill_in "SpD IVs", with: "31"
      fill_in "Spe IVs", with: "31"

      fill_in "Move 1", with: "Earthquake"
      fill_in "Move 2", with: "Dragon Claw"
      fill_in "Move 3", with: "Wish"       # illegal for Garchomp
      fill_in "Move 4", with: "Protect"

      fill_in "Tera Type", with: "Ground"
    end

    click_button "Save"

    within "#slot-1" do
      # AC3: error on Moves
      moves_label = find("label", text: "Moves")
      moves_container = moves_label.ancestor(".moves-field-group")

      expect(moves_container).to have_content("Move cannot be learned")

      # AC3: Illegal badge
      expect(page).to have_css(".badge-illegal", text: "Illegal")

      # AC3: link that focuses the invalid field
      link = find("a[data-role='move-error-link']")
      expect(link[:href]).to include("#slot_1_move_3")
    end
  end
end
