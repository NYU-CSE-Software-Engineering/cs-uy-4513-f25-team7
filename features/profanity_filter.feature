Feature: Profanity filtering
  As a community member
  I want profanity to be blocked in posts and direct messages
  So that the forum stays friendly

  Background:
    Given I am signed in
    And there exists another user named "Misty"

  @ui @sad
  Scenario: Cannot create a post with profanity in the body
    When I go to the new post page
    And I fill in "Title" with "Rude post"
    And I select "Thread" from "Post Type"
    And I fill in "Body" with "This post is darn rude"
    And I press "Create Post"
    Then I should see "Body contains inappropriate language"

  @ui @sad
  Scenario: Cannot create a post with profanity in the title
    When I go to the new post page
    And I fill in "Title" with "This darn title is rude"
    And I select "Thread" from "Post Type"
    And I fill in "Body" with "This body is clean"
    And I press "Create Post"
    Then I should see "Title contains inappropriate language"

  @ui @sad
  Scenario: Cannot send a direct message with profanity
    When I navigate to the profile page for "Misty"
    And I press "Send Message"
    And I fill in "Subject" with "Not nice"
    And I fill in "Body" with "This is darn rude"
    And I press "Send Message"
    Then I should see "Body contains inappropriate language"
