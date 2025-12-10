Feature: Team Rating & Reviews
  As a competitive Pokémon player browsing the forum
  I want to rate and review published teams
  So that I can provide feedback to team builders and help others discover quality team compositions

  Background:
    Given a user exists with email "owner@example.com" and password "password123"
    And a user exists with email "reviewer@example.com" and password "password123"
    And a published public team "Rain Balance" exists owned by "owner@example.com"

  Scenario: Submit a review on a published team
    Given I am logged in as "reviewer@example.com" with password "password123"
    When I visit the team page for "Rain Balance"
    Then I should see "Write a Review"
    When I select a rating of 4 stars
    And I fill in the review body with "Great synergy between Pelipper and Ludicolo!"
    And I click "Submit Review"
    Then I should see "Review submitted successfully"
    And I should see "4.0"
    And I should see "Great synergy between Pelipper and Ludicolo!"

  Scenario: Cannot review your own team
    Given I am logged in as "owner@example.com" with password "password123"
    When I visit the team page for "Rain Balance"
    Then I should see "You cannot review your own team"
    And I should not see "Write a Review"

  Scenario: Edit an existing review
    Given I am logged in as "reviewer@example.com" with password "password123"
    And I have already reviewed "Rain Balance" with 3 stars and body "Okay team"
    When I visit the team page for "Rain Balance"
    Then I should see "Your Review"
    And I should see "Okay team"
    When I click "Edit"
    And I select a rating of 5 stars
    And I fill in the review body with "Actually this team is amazing!"
    And I click "Update Review"
    Then I should see "Review updated successfully"
    And I should see "Actually this team is amazing!"

  Scenario: Delete my own review
    Given I am logged in as "reviewer@example.com" with password "password123"
    And I have already reviewed "Rain Balance" with 4 stars and body "Nice team"
    When I visit the team page for "Rain Balance"
    And I click "Delete"
    Then I should see "Review deleted"
    And I should see "No reviews yet"

  Scenario: View team ratings summary
    Given I am logged in as "reviewer@example.com" with password "password123"
    And the team "Rain Balance" has the following reviews:
      | user                  | rating | body           |
      | user1@example.com     | 5      | Excellent!     |
      | user2@example.com     | 4      | Very good      |
      | user3@example.com     | 3      | Decent         |
    When I visit the team page for "Rain Balance"
    Then I should see "4.0"
    And I should see "3 reviews"

  Scenario: Moderator can remove inappropriate reviews
    Given a moderator exists with email "mod@example.com" and password "modpass123"
    And I am logged in as "reviewer@example.com" with password "password123"
    And I have already reviewed "Rain Balance" with 1 star and body "This team sucks!"
    When I log out
    And I am logged in as "mod@example.com" with password "modpass123"
    And I visit the team page for "Rain Balance"
    Then I should see "This team sucks!"
    When I click "Remove (Mod)"
    Then I should see "Review removed by moderator"
    And I should not see "This team sucks!"

  Scenario: Must be logged in to review
    When I visit the team page for "Rain Balance"
    Then I should see "Log in to leave a review"
    And I should not see "Write a Review"

