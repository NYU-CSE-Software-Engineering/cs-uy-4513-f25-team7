Feature: Pokémon species lookup
  As a user of the PokéForum platform
  I want to look up Pokémon species by name
  So that I can use them in various tools (team builder, discussions, etc.)

  Background:
    # Assume reference data already exists (from seeds or PokeAPI import).
    Given the Pokédex has species data:
      | name      |
      | Pelipper  |
      | Ludicolo  |
      | Garchomp  |

  # --- AC1: Exact match lookup ---

  Scenario: Lookup by full species name returns a single match
    When I request a species lookup with query "Pelipper"
    Then the species lookup JSON should include these species:
      | name     |
      | Pelipper |
    And the species lookup JSON should not include species "Ludicolo"
    And the species lookup JSON should not include species "Garchomp"

  # --- AC2: Partial match / autocomplete ---

  Scenario: Lookup by partial string returns matching suggestions
    When I request a species lookup with query "gar"
    Then the species lookup JSON should include these species:
      | name     |
      | Garchomp |
    And the species lookup JSON should not include species "Pelipper"

  # --- AC3: Case-insensitive matching ---

  Scenario: Lookup ignores case
    When I request a species lookup with query "pELipPer"
    Then the species lookup JSON should include these species:
      | name     |
      | Pelipper |

  # --- AC4: No results for nonsense query ---

  Scenario: Lookup returns empty list for unknown species
    When I request a species lookup with query "asdfghjkl"
    Then the species lookup JSON should be empty
