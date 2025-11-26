Given("I am on the Team Editor page for a new team") do
  visit new_team_path
  expect(page).to have_content("Team Editor").or have_button("Save")
end

### AC1 — Create/Edit/Save 1–6

When(/^I set the team name to "([^"]*)"$/) do |team_name|
  fill_in "Team Name", with: team_name
end

When(/^I add Pokémon slot (\d+) with:$/) do |slot_number, table|
  data = table.rows_hash
  slot_el = find_slot(slot_number.to_i)

  set_field("Species",   data["Species"],   scope: slot_el) if data["Species"]
  set_field("Item",      data["Item"],      scope: slot_el) if data["Item"]
  set_field("Ability",   data["Ability"],   scope: slot_el) if data["Ability"]
  set_field("Nature",    data["Nature"],    scope: slot_el) if data["Nature"]
  set_field("Tera Type", data["Tera Type"], scope: slot_el) if data["Tera Type"]
  set_field("Nickname",  data["Nickname"],  scope: slot_el) if data["Nickname"]

  if data["EVs"]
    evs = parse_evs(data["EVs"])
    fill_evs_in_slot(slot_el, evs)
  end

  if data["IVs"]
    ivs = parse_ivs(data["IVs"])
    fill_ivs_in_slot(slot_el, ivs)
  end

  if data["Moves"]
    moves = data["Moves"].split(',').map(&:strip)
    fill_moves_in_slot(slot_el, moves)
  end
end

When(/^I add Pokémon slots (\d+) through (\d+) with valid configurations$/) do |start_idx, end_idx|
  (start_idx.to_i..end_idx.to_i).each do |i|
    step %{I add Pokémon slot #{i} with:}, table(%{
      | Species   | Pikachu       |
      | Item      | Focus Sash    |
      | Ability   | Static        |
      | Nature    | Timid         |
      | EVs       | 0 HP / 0 Atk / 0 Def / 252 SpA / 4 SpD / 252 Spe |
      | IVs       | 31 / 0 / 31 / 31 / 31 / 31 |
      | Moves     | Thunderbolt, Volt Switch, Protect, Fake Out |
      | Tera Type | Electric      |
    })
  end
end

When(/^I press "([^"]*)"$/) do |button_text|
  click_button button_text
end

# Then(/^I should see "([^"]*)"$/) do |text|
#   expect(page).to have_content(text)
# end

Then(/^I should see in the Team Editor "([^"]*)"$/) do |text|
  # scope to the team editor area if you have a wrapper
  if page.has_css?('.team-editor')
    within('.team-editor') do
      expect(page).to have_content(text)
    end
  else
    # fallback if you haven't wrapped the page yet
    expect(page).to have_content(text)
  end
end

Then("the team should be persisted as a draft owned by me") do
  expect(page).to have_content("Draft")
  expect(page).to have_content("Owned by me")
end


Then("I should see a last-saved timestamp") do
  expect(page).to have_content("Last saved").or have_css("[data-last-saved]")
end

Given("I have already added 6 Pokémon to the team") do
  (1..6).each do |i|
    step %{I add Pokémon slot #{i} with:}, table(%{
      | Species   | Pelipper      |
      | Item      | Damp Rock     |
      | Ability   | Drizzle       |
      | Nature    | Bold          |
      | EVs       | 252 HP / 0 Atk / 196 Def / 0 SpA / 60 SpD / 0 Spe |
      | IVs       | 31 / 0 / 31 / 31 / 31 / 31 |
      | Moves     | Hurricane, Tailwind, Wide Guard, Protect |
      | Tera Type | Water         |
    })
  end
end

When("I try to add a 7th Pokémon") do
  click_button "Add Pokémon" if page.has_button?("Add Pokémon")
end

Then("the team should still show exactly 6 Pokémon slots") do
  expect(page).to have_css('[id^="slot-"]', count: 6).or have_css('[data-slot]', count: 6)
end

### AC2 — Per-Pokémon Legality (no formats in this iteration)

# Matches: And I select the move "Wish" (which Garchomp cannot learn)
When(/^I select the move "([^"]*)" \(which .+ cannot learn\)$/) do |move_name|
  slot_el = find_slot(1)
  fill_moves_in_slot(slot_el, [move_name])
end

Then(/^the field "([^"]*)" should show an error "([^"]*)"$/) do |field_label, message|
  field = find('label', text: field_label, exact: false)
  container = field.first(:xpath, './/..') # parent
  expect(container).to have_content(message)
end

Then(/^the Pokémon card for slot (\d+) should display an "([^"]*)" badge$/) do |slot_number, badge_text|
  slot_el = find_slot(slot_number.to_i)
  within(slot_el) { expect(page).to have_content(badge_text) }
end

Then("there should be a link or focus that brings me to the invalid field") do
  expect(page).to have_css('.field-error a, a[href*="error"]', wait: 0.5).or have_css('.is-invalid:focus', wait: 0.5)
end

Given("slot 1 shows an {string} badge for an illegal move") do |badge|
  step %{the Pokémon card for slot 1 should display an "#{badge}" badge}
end

When(/^I replace the illegal move with a legal move "([^"]*)"$/) do |move_name|
  slot_el = find_slot(1)
  fill_moves_in_slot(slot_el, [move_name])
end

Then(/^the error on "([^"]*)" should disappear$/) do |field_label|
  field = find('label', text: field_label, exact: false)
  container = field.first(:xpath, './/..')
  expect(container).not_to have_css('.error, .field-error', wait: 1)
end

# Accept both phrasings:
Then(/^the Pokémon (?:card )?for slot (\d+) should no longer display an "([^"]*)" badge$/) do |slot_number, badge_text|
  slot_el = find_slot(slot_number.to_i)
  within(slot_el) { expect(page).not_to have_content(badge_text) }
end

### AC3 — Save/Draft/Publish/Visibility (no formats)

Given("my team has unresolved legality errors") do
  # Create an illegal state (e.g., a move your validator marks illegal for that species)
  step %{I add Pokémon slot 1 with:}, table(%{
    | Species   | Garchomp |
    | Item      | Choice Band |
    | Ability   | Rough Skin |
    | Nature    | Jolly |
    | EVs       | 0 HP / 252 Atk / 4 Def / 0 SpA / 0 SpD / 252 Spe |
    | IVs       | 31 / 31 / 31 / 31 / 31 / 31 |
    | Moves     | Wish, Earthquake, Dragon Claw, Protect |
    | Tera Type | Ground |
  })
end

Then("the team should be saved as a private draft") do
  expect(page).to have_content("Draft")
  expect(page).to have_content("Private").or have_content("Visibility: Private")
end

Then("I should see an error summary listing all unresolved issues") do
  expect(page).to have_css("#error-summary, .error-summary, [data-role='error-summary']")
end

Then("I should see that Publish is disabled") do
  expect(page).to have_button("Publish", disabled: true).or have_css('[data-action="publish"][aria-disabled="true"]')
end

Given("my team passes validation") do
  # Fill two simple, presumably legal Pokémon; expand to all 6 if your validator requires it.
  step %{I add Pokémon slot 1 with:}, table(%{
    | Species   | Pelipper |
    | Item      | Damp Rock |
    | Ability   | Drizzle |
    | Nature    | Bold |
    | EVs       | 252 HP / 0 Atk / 196 Def / 0 SpA / 60 SpD / 0 Spe |
    | IVs       | 31 / 0 / 31 / 31 / 31 / 31 |
    | Moves     | Hurricane, Tailwind, Wide Guard, Protect |
    | Tera Type | Water |
  })
  step %{I add Pokémon slot 2 with:}, table(%{
    | Species   | Ludicolo |
    | Item      | Life Orb |
    | Ability   | Swift Swim |
    | Nature    | Modest |
    | EVs       | 4 HP / 0 Atk / 0 Def / 252 SpA / 0 SpD / 252 Spe |
    | IVs       | 31 / 0 / 31 / 31 / 31 / 31 |
    | Moves     | Hydro Pump, Giga Drain, Ice Beam, Protect |
    | Tera Type | Water |
  })
  click_button "Validate" if page.has_button?("Validate")
  expect(page).to have_content("Legal").or have_css('.badge-legal')
end

When(/^I set the visibility to "([^"]*)"$/) do |vis|
  select vis, from: "Visibility"
end

Then("I should be on the team’s public page") do
  expect(page).to have_current_path(%r{/teams/\d+})
  expect(page).to have_content("Public").or have_content("Visibility: Public")
end

Then(/^I should see a legality badge "([^"]*)"$/) do |badge_text|
  expect(page).to have_content(badge_text).or have_css('.badge-legal')
end

Then("I should have a shareable URL") do
  expect(page.current_url).to match(%r{/teams/\d+})
end