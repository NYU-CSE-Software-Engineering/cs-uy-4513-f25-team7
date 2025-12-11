Feature: Pagination
  As a user
  I want to navigate through paginated lists of posts, users, and notifications
  So that I can efficiently browse large amounts of content

  Background:
    Given I am a registered user
    And I am signed in

  Scenario: View paginated posts list
    Given there are 25 posts
    When I visit the posts index page
    Then I should see 10 posts per page
    And I should see pagination controls

  Scenario: Navigate to second page of posts
    Given there are 25 posts
    When I visit the posts index page
    And I click on page "2"
    Then I should be on page 2
    And I should see 10 posts per page

  Scenario: View paginated users list
    Given there are 25 users
    When I visit the users index page
    Then I should see 20 users per page
    And I should see pagination controls

  Scenario: Navigate to second page of users
    Given there are 25 users
    When I visit the users index page
    And I click on page "2"
    Then I should be on page 2
    And I should see 5 users per page

  Scenario: View paginated notifications
    Given there are 25 notifications for the current user
    When I visit the notifications page for pagination
    Then I should see 20 notifications per page
    And I should see pagination controls

  Scenario: Navigate to second page of notifications
    Given there are 25 notifications for the current user
    When I visit the notifications page for pagination
    And I click on page "2"
    Then I should be on page 2
    And I should see 5 notifications per page

  Scenario: No pagination for small lists
    Given there are 5 posts
    When I visit the posts index page
    Then I should see 5 posts
    And I should not see pagination controls
