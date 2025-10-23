Feature: Team Editor (Build & Share Competitive Teams)
  As a registered forum user who builds teams
  I want to create and edit competitive Pokémon teams
  So that I can share them for feedback, discuss strategy, and use them in forum tournaments

  Background:
    Given I am a signed-in user
    And I am on the Team Editor page for a new team

  # --- AC1: Create, Edit, and Save a Team (1–6 Pokémon) ---

  Scenario: Create a valid draft team with up to 6 Pokémon
    When I set the team name to "Rain Balance"
    And I add Pokémon slot 1 with:
      | Species   | Pelipper |
      | Item      | Damp Rock |
      | Ability   | Drizzle |
      | Nature    | Bold |
      | EVs       | 252 HP / 0 Atk / 196 Def / 0 SpA / 60 SpD / 0 Spe |
      | IVs       | 31 / 0 / 31 / 31 / 31 / 31 |
      | Moves     | Hurricane, Tailwind, Wide Guard, Protect |
      | Tera Type | Water |
    And I add Pokémon slot 2 with:
      | Species   | Ludicolo |
      | Item      | Life Orb |
      | Ability   | Swift Swim |
      | Nature    | Modest |
      | EVs       | 4 HP / 0 Atk / 0 Def / 252 SpA / 0 SpD / 252 Spe |
      | IVs       | 31 / 0 / 31 / 31 / 31 / 31 |
      | Moves     | Hydro Pump, Giga Drain, Ice Beam, Protect |
      | Tera Type | Water |
    And I add Pokémon slots 3 through 6 with valid configurations
    And I press "Save"
    Then I should see "Saved draft: Rain Balance"
    And the team should be persisted as a draft owned by me
    And I should see a last-saved timestamp

  Scenario: Attempting to add a 7th Pokémon is rejected (non-blocking)
    Given I have already added 6 Pokémon to the team
    When I try to add a 7th Pokémon
    Then I should see "A team can have at most 6 Pokémon"
    And the team should still show exactly 6 Pokémon slots

  Scenario: Inline legality validation marks illegal selections
    When I add Pokémon slot 1 with:
      | Species   | Garchomp |
      | Item      | Choice Band |
      | Ability   | Rough Skin |
      | Nature    | Jolly |
      | EVs       | 0 HP / 252 Atk / 4 Def / 0 SpA / 0 SpD / 252 Spe |
      | IVs       | 31 / 31 / 31 / 31 / 31 / 31 |
      | Moves     | Earthquake, Dragon Claw, Wish, Protect |
      | Tera Type | Ground |
    And I select the move "Wish" (which Garchomp cannot learn)
    Then the field "Moves" should show an error "Move cannot be learned"
    And the Pokémon card for slot 1 should display an "Illegal" badge
    And there should be a link or focus that brings me to the invalid field

  Scenario: Fixing illegality clears the error state
    Given slot 1 shows an "Illegal" badge for an illegal move
    When I replace the illegal move with a legal move "Rock Slide"
    Then the error on "Moves" should disappear
    And the Pokémon for slot 1 should no longer display an "Illegal" badge

  Scenario: Save as Draft with unresolved errors keeps a private draft and shows summary
    Given my team has unresolved legality errors
    When I press "Save"
    Then the team should be saved as a private draft
    And I should see an error summary listing all unresolved issues
    And I should see that Publish is disabled

  Scenario: Publish a fully legal team to a public page
    Given my team passes validation
    And I set the visibility to "Public"
    When I press "Publish"
    Then I should be on the team’s public page
    And I should see a legality badge "Legal"
    And I should have a shareable URL

