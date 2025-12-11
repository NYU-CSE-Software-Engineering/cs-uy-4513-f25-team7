Feature: Advanced Tagging Features
  As a forum user
  I want to see popular tags and tag statistics
  So that I can discover trending topics and understand tag usage

  Background:
    Given I am a registered user
    And I am signed in

  Scenario: View popular tags on homepage
    Given there are posts with the following tag usage:
      | Tag | Usage Count |
      | ruby | 5 |
      | rails | 3 |
      | javascript | 2 |
      | programming | 4 |
    When I am on the forum homepage for advanced tagging
    Then I should see popular tags ordered by usage
    And "ruby" should be the most popular tag
    And "programming" should be the second most popular tag

  Scenario: View tag usage statistics
    Given there are posts with the following tag usage:
      | Tag | Usage Count |
      | ruby | 10 |
      | rails | 8 |
      | javascript | 5 |
    When I am on the forum homepage for advanced tagging
    Then I should see tag usage statistics
    And "ruby" should show "10 posts"
    And "rails" should show "8 posts"
    And "javascript" should show "5 posts"

  Scenario: Click popular tag to filter posts
    Given there are posts with the following tag usage:
      | Tag | Usage Count |
      | ruby | 5 |
      | rails | 3 |
    And there are posts with the following tags:
      | Title | Tags |
      | Ruby Basics | ruby, basics |
      | Rails Tutorial | rails, tutorial |
      | Ruby on Rails | ruby, rails |
    When I am on the forum homepage for advanced tagging
    And I click on a popular tag "ruby"
    Then I should see "Ruby Basics"
    And I should see "Ruby on Rails"
    And I should not see "Rails Tutorial"

  Scenario: Tag uniqueness and normalization
    Given there is already a tag named "ruby"
    When I create a post with the tag "RUBY"
    Then the post should be associated with the existing "ruby" tag
    And there should not be a duplicate "RUBY" tag

  Scenario: Tag validation for long names
    Given I am on the new post page
    When I fill in "Title" with "Validation Test"
    And I fill in "Body" with "Testing tag validation"
    And I fill in "Tags" with "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    And I press "Create Post"
    Then I should see a validation error
    And the post should not be created
