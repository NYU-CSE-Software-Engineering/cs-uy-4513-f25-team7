Feature: Forum posts, meta posts, and comments
  As a signed-in member
  I want to create posts (including meta posts) and comment on posts
  So that I can share updates and discuss strategies with the community

  Background:
    Given I am signed in

  @happy
  Scenario: Create a standard post successfully
    When I go to the new post page
    And I fill in "Title" with "Best lead choices for OU"
    And I select "Thread" from "Post Type"
    And I fill in "Body" with "I like Landorus-T as a lead for pivoting."
    And I press "Create Post"
    Then I should be on the post show page
    And I should see "Post was successfully created."
    And I should see "Best lead choices for OU"
    And I should see "Landorus-T"

  @happy
  Scenario: Create a meta post successfully
    When I go to the new post page
    And I fill in "Title" with "VGC 2025 meta snapshot"
    And I select "Meta" from "Post Type"
    And I fill in "Body" with "Ice Spinner tech is trending."
    And I press "Create Post"
    Then I should be on the post show page
    And I should see "VGC 2025 meta snapshot"
    And I should see a meta badge

  @happy
  Scenario: Comment on a post
    Given a post titled "EV spreads for bulky offense" exists
    When I view the post "EV spreads for bulky offense"
    And I fill in "Add a comment" with "Try 244 HP / 28 Def / 236 Spe."
    And I press "Post Comment"
    Then I should see "Comment posted."
    And I should see "244 HP / 28 Def / 236 Spe."

  @sad
  Scenario: Fail to create a post without a title
    When I go to the new post page
    And I fill in "Body" with "Missing title here."
    And I press "Create Post"
    Then I should see "Title can't be blank"

  @sad
  Scenario: I cannot comment
    Given I sign out
    And a post titled "Hazard removal options" exists
    When I view the post "Hazard removal options"
    Then I should not see the comment form
    And I should see "Please sign in to comment."
