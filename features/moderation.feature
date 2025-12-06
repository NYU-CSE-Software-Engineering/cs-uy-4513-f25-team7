Feature: Role Assignment (Moderation Controls)
  As an admin
  I want to assign or remove the “moderator” role from other members
  So that I can control who has access to moderation tools on the Pokémon platform

  Background:
    Given the following users exist:
      | email           | role   |
      | admin@poke.com  | admin  |
    And I am signed in as "admin@poke.com"
    And I am on the Role Management page


  # --- AC1: Promote a User to Moderator ---

  Scenario: Promote a user to moderator
    Given the following users exist:
      | email           | role      |
      | ash@poke.com    | user      |
      | misty@poke.com  | user      |
    When I click "Promote" for "ash@poke.com"
    Then I should see "ash@poke.com is now a moderator"
    And "ash@poke.com" should appear in the list with role "Moderator"
    And I should see a success banner "Role updated successfully"

  # --- AC2: Demote a Moderator to User ---

  Scenario: Demote a moderator to user
    Given the following users exist:
      | email           | role       |
      | brock@poke.com  | moderator  |
      | may@poke.com    | moderator  |
    When I click "Demote" for "may@poke.com"
    Then I should see "may@poke.com is now a user"
    And "may@poke.com" should appear in the list with role "User"
    And I should see a success banner "Role updated successfully"

  # --- AC3: Authorization Restrictions ---

  Scenario: Regular user cannot access the Role Management page
    Given the following users exist:
      | email           | role  |
      | ash@poke.com    | user  |
    And I am signed in as "ash@poke.com"
    When I visit the Role Management page
    Then I should see "Not authorized"
    And I should not see any "Promote" or "Demote" buttons

  # --- AC4: Safety Rule - Prevent Removing Final Moderator ---

  Scenario: Last moderator cannot demote themselves
    Given the following users exist:
      | email           | role       |
      | mod@poke.com    | moderator  |
    And I am signed in as "mod@poke.com"
    And I am on the Role Management page
    When I click "Demote" for "mod@poke.com"
    Then I should see "There must be at least one moderator on the platform"
    And "mod@poke.com" should remain listed as a moderator
    And I should see an error banner "Action not allowed"

  # New: Moderator cannot see Role Management

  Scenario: Moderator cannot manage roles
    Given the following users exist:
      | email           | role       |
      | admin@poke.com  | admin      |
      | mod@poke.com    | moderator  |
    And I am signed in as "mod@poke.com"
    When I visit the Role Management page directly
    Then I should see "Not authorized"

  # New: There can only be one admin

  Scenario: Cannot promote a second admin
    Given the following users exist:
      | email            | role   |
      | admin@poke.com   | admin  |
      | ash@poke.com     | user   |
    And I am signed in as "admin@poke.com"
    And I am on the Role Management page
    When I click "Promote" for "ash@poke.com" to admin
    Then I should see "There can only be one admin on the platform"

  Scenario: Cannot demote the last admin
    Given the following users exist:
      | email            | role   |
      | admin@poke.com   | admin  |
    And I am signed in as "admin@poke.com"
    And I am on the Role Management page
    When I attempt to demote "admin@poke.com" to "user"
    Then I should see "There must be at least one admin on the platform"
