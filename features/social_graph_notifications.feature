Feature: Social graph and notifications
  As a signed-in member
  I want to follow users and favorite content
  So that I get notifications in my inbox

  Background:
    Given I am signed in for social notifications
    And there exists another user named "Misty"
    And there exists a public team called "Rain Dance" owned by "Misty"

  # --- AC1: Follow a user ---

  @happy
  Scenario: Follow a user successfully
    When I navigate to the profile page for "Misty"
    And I click "Follow"
    Then I should see the social message "Following"
    And I should see "1 follower" on Misty's profile
    And a new notification should exist for "Misty"

  @sad
  Scenario: Cannot follow the same user twice
    Given I already follow the user "Misty"
    When I click "Follow"
    Then I should see an error "Already following"
    And I should still see "1 follower" on Misty's profile

  @sad
  Scenario: Cannot follow myself
    When I visit my own profile page
    Then I should not see a follow button

  # --- AC2: Favorite a team/post ---

  @happy
  Scenario: Favorite a team successfully
    When I go to the team page for "Rain Dance"
    And I click "Favorite"
    Then I should see the social message "Favorited"
    And I should find "Rain Dance" in My Favorites
    And a new notification should exist for "Misty"

  @sad
  Scenario: Prevent duplicate favorite on the same team
    Given I am on the team page for "Rain Dance"
    And I have already favorited the team "Rain Dance"
    When I click "Favorite"
    Then I should see an error message
    And I should still see "Favorited"

  # --- AC3: Notifications inbox ---

  @happy
  Scenario: View notifications newest-first and mark as read
    Given I have at least one unread notification
    When I visit the notifications page
    Then I should see my newest notification listed first
    And the unread badge should be visible
    And my unread notifications should be marked as read

  @sad
  Scenario: Must be signed in to follow or favorite
    Given I sign out for social notifications
    When I navigate to the profile page for "Misty"
    And I click "Follow"
    Then I should be on the sign in page
    And I should see the social message "Please sign in to continue"
