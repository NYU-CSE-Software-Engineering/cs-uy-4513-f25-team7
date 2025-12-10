Feature: post tagging system
  As a forum user
  I want to categorize my posts with tags
  So that I can organize content and help others find relevant posts through tag-based filtering and search

  Background:
    Given the forum is running
    And I am on the forum homepage

  Scenario: user creates a post with valid tags
    Given I am on the new post page
    When I fill in "Title" with "Ruby on Rails Best Practices"
    And I fill in "Content" with "Here are some best practices for Ruby on Rails development..."
    And I fill in "Tags" with "ruby, rails, best-practices, programming"
    And I press "Create Post"
    Then I should be on the post's show page
    And I should see the message "Post was successfully created"
    And I should see the title "Ruby on Rails Best Practices"
    And I should see the tags "ruby", "rails", "best-practices", "programming"

  Scenario: user creates a post without tags
    Given I am on the new post page
    When I fill in "Title" with "General Discussion"
    And I fill in "Content" with "This is a general discussion post"
    And I leave "Tags" empty
    And I press "Create Post"
    Then I should be on the post's show page
    And I should see the message "Post was successfully created"
    And I should see the title "General Discussion"
    And I should not see any tags

  Scenario: user creates a post with empty and whitespace tags
    Given I am on the new post page
    When I fill in "Title" with "Test Post"
    And I fill in "Content" with "Testing tag normalization"
    And I fill in "Tags" with "ruby, , rails,   , programming"
    And I press "Create Post"
    Then I should be on the post's show page
    And I should see the message "Post was successfully created"
    And I should see the title "Test Post"
    And I should see the tags "ruby", "rails", "programming"

  Scenario: user creates a post with tags that need normalization
    Given I am on the new post page
    When I fill in "Title" with "Normalization Test"
    And I fill in "Content" with "Testing tag normalization"
    And I fill in "Tags" with "  RUBY  ,  Rails  ,  Programming  "
    And I press "Create Post"
    Then I should be on the post's show page
    And I should see the message "Post was successfully created"
    And I should see the title "Normalization Test"
    And I should see the tags "ruby", "rails", "programming"

  Scenario: user fails to create a post without a title
    Given I am on the new post page
    When I fill in "Content" with "This post has no title"
    And I fill in "Tags" with "test, example"
    And I press "Create Post"
    Then I should see an error message indicating the title is missing
    And I should still be on the new post page

  Scenario: user fails to create a post without content
    Given I am on the new post page
    When I fill in "Title" with "Post Without Content"
    And I fill in "Tags" with "test, example"
    And I press "Create Post"
    Then I should see an error message indicating the content is missing
    And I should still be on the new post page

  Scenario: user filters posts by tag
    Given there are posts with the following tags:
      | Title | Tags |
      | Ruby Basics | ruby, programming |
      | Rails Tutorial | rails, tutorial |
      | JavaScript Guide | javascript, programming |
    When I am on the posts index page
    And I select "ruby" from the tag filter
    And I press "Search"
    Then I should see "Ruby Basics"
    And I should not see "Rails Tutorial"
    And I should not see "JavaScript Guide"

  Scenario: user searches posts by tag name
    Given there are posts with the following tags:
      | Title | Tags |
      | Ruby Guide | ruby, guide |
      | Rails Tutorial | rails, tutorial |
      | JavaScript Basics | javascript, basics |
    When I am on the posts index page
    And I fill in the search field with "ruby"
    And I press "Search"
    Then I should see "Ruby Guide"
    And I should not see "Rails Tutorial"
    And I should not see "JavaScript Basics"

  Scenario: user clicks on a tag to filter posts
    Given there are posts with the following tags:
      | Title | Tags |
      | Ruby Basics | ruby, programming |
      | Rails Advanced | rails, advanced |
      | Ruby on Rails | ruby, rails |
    When I am on the posts index page
    And I click on the "ruby" tag
    Then I should see "Ruby Basics"
    And I should see "Ruby on Rails"
    And I should not see "Rails Advanced"

  Scenario: user clears tag filter to see all posts
    Given I have filtered posts by the "ruby" tag
    And I can see only Ruby-related posts
    When I press "Clear"
    Then I should see all posts
    And the tag filter should be empty
