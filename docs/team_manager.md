Feature: Team Editor (Build & Share Competitive Teams)

User Story
    As a registered forum user who builds teams, I want to create and edit competitive Pokémon teams 
    (species, moves, items, abilities, EVs/IVs, nicknames, format) so that I can share them for feedback, 
    discuss strategy, and use them in forum tournaments.

Acceptance Criteria

AC1 — Create, Edit, and Save a Team (1–6 Pokémon)
    Given I am logged in
    And I am on the Team Editor page
    When I add between 1 and 6 Pokémon with species, item, ability, moves (0–4), EVs/IVs (optional), and a nickname (optional)
    And I click Save
    Then the team is persisted to my account as a draft
    And I see a success message with the team name and last-saved timestamp.

    Sad path
    When I attempt to add a 7th Pokémon
    Then I see a non-blocking error “A team can have at most 6 Pokémon”
    And the 7th slot is not added.

AC2 — Per-Pokémon Legality (Regional Dex, Moves, Abilities)
    Given I add or edit a Pokémon
    When I choose species, ability, held item, nature, EVs/IVs, moves, and Tera Type
    Then the editor validates that each choice is legal for the selected game/format 
    (e.g., learnset available in SV, item allowed, Hidden Ability released, Tera Type allowed).
    
    Sad path 
    If any selection is illegal (e.g., move unobtainable in SV), the field shows a clear error 
    message with a link to fix; the Pokémon card gets a red “Illegal” badge.

AC3 — Save, Draft, Publish, and Visibility
    Given I am logged in
    When I Save a team with unresolved errors
    Then it’s saved as Draft (private to me) with an error summary retained.
    When the team is fully legal
    And I click Publish
    Then the team is Public with a shareable page (including format tag, version, and legality badge).
    
    Sad path
    Attempting to Publish with any unresolved error shows a consolidated checklist and focuses 
    the first failing field.


--------------------------------------------------------------------------------------

MVC Component Outline

------------------------

Models 

Team
    Attributes:
    user_id: references (owner)
    name: string (optional; default “Untitled Team”)
    status: enum {draft, published} (default: draft)
    visibility: enum {private, unlisted, public} (default: private)
    notes: text
    last_validated_at: datetime
    legality_state: enum {unknown, valid, invalid} (cached summary)
    Assoc: belongs_to :user, belongs_to :format; has_many :team_slots, dependent: :destroy
    Validations: max 6 team_slots

TeamSlot (1–6 “cards” in a team)
    Attributes:
    team_id: references
    position: integer (1–6, unique per team)
    species_id: references
    nickname: string
    ability_id: references
    item_id: references
    nature_id: references
    tera_type: enum {Normal, Fire, Water, …}
    ev_hp/ev_atk/ev_def/ev_spa/ev_spd/ev_spe: integer (0–252)
    iv_hp/iv_atk/iv_def/iv_spa/iv_spd/iv_spe: integer (0–31)
    Assoc: belongs_to :team; has_many :move_slots, dependent: :destroy
    Validations: EV per-stat ≤ 252, sum(EVs) ≤ 510; IVs in 0–31

MoveSlot (0–4 per TeamSlot)
    Attrs:
    team_slot_id: references
    move_id: references
    index: integer (0–3)
    Assoc: belongs_to :team_slot
    Validations: max 4 per team_slot, unique move_id per card

LegalityIssue (optional, for detailed feedback)
    Attrs:
    team_id: references (nullable)
    team_slot_id: references (nullable)
    field: string (e.g., "move_id", "item_id", "ev_total")
    code: string (e.g., item_clause_violation, unlearnable_move)
    message: text
    Assoc: belongs to Team and/or TeamSlot
    Usage: Store results of last validate run; surfaced in UI.

------------------------

Views

Teams (Editor & Read Views)
    teams/new.html.erb — Empty team editor (creates draft);
    teams/edit.html.erb — Team Editor UI with:
        Team header (name, visibility, status (legal/illegal))
        1–6 _team_slot_card partials (species, ability, item, nature, EV/IV editors, Tera Type)
        Inline legality badges + errors per field
        Move picker with search + recent moves
        Toolbar: Save (Draft), Validate, Publish, Export, Import
    teams/show.html.erb — Published/Public team page (read-only, shareable URL), 
        includes six Pokemon, and optional forum post link/comments.

------------------------

Controllers

TeamsController
    new — initialize draft (default format); render editor.
    create — persist draft with nested team_slots/move_slots.
    edit — load draft or published (owner only for edit).
    update — update draft/published (restrict edits if published, or require reversion to draft).
    show — public view of published; owner can see drafts.
    publish (PATCH) — run validation; if valid, set status=published, visibility=public|unlisted per choice.
    unpublish (PATCH, optional) — revert to draft/private.
    Strong params support nested attributes for team_slots and move_slots.

TeamValidationsController
create (POST /teams/:id/validate) — checks legality; 
    updates Team.legality_state;


