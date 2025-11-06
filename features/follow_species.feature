Feature: Follow a Pokémon species to personalize the feed
  As a signed-in user
  I want to follow/unfollow a species
  So that my home feed prioritizes discussions I care about

  Background:
    Given I am signed in
    And the following species exist:
      | name       |
      | Pelipper   |
      | Iron Hands |

  @ui
  Scenario: Follow a species from its page
    Given I am on the "Pelipper" species page
    When I click the follow button
    Then I should see the button change to "Unfollow"
    And I should see the follower count increase by 1


  @ui
  Scenario: Unfollow a species
    Given I already follow "Pelipper"
    And I am on the "Pelipper" species page
    When I click the unfollow button
    Then I should see the button change to "Follow"
    And I should see the follower count decrease by 1

  @ui
  Scenario: Home feed prioritizes posts from followed species
    Given I already follow "Pelipper" and "Iron Hands"
    And there are 5 recent posts tagged with any of "Pelipper, Iron Hands"
    And there are 10 recent posts without any followed species
    When I visit my home feed
    Then the first 5 posts in the feed should be from "Pelipper, Iron Hands"

  @ui
  Scenario: Show follower count on species page
    Given "Iron Hands" has 3 followers
    When I am on the "Iron Hands" species page
    Then I should see a follower count of 3

  @ui
  Scenario: Show a "Following" badge next to species I follow
    Given I already follow "Pelipper"
    When I search for species "Pelipper"
    Then I should see a "Following" badge next to "Pelipper"
