Feature: Post Tagging System
  As a forum user
  I want to categorize posts with tags
  So that I can organize content and help others find relevant posts

  Background:
    Given the forum is running
    And I am on the forum homepage

  Scenario: Create a new post with tags
    Given I am on the new post page
    When I fill in "Title" with "Ruby on Rails Best Practices"
    And I fill in "Content" with "Here are some best practices for Ruby on Rails development..."
    And I fill in "Tags" with "ruby, rails, best-practices, programming"
    And I click "Create Post"
    Then I should see "Post was successfully created"
    And I should see "Ruby on Rails Best Practices"
    And I should see the tags "ruby", "rails", "best-practices", "programming"

  Scenario: Create a post without tags
    Given I am on the new post page
    When I fill in "Title" with "General Discussion"
    And I fill in "Content" with "This is a general discussion post"
    And I leave "Tags" empty
    And I click "Create Post"
    Then I should see "Post was successfully created"
    And I should see "General Discussion"
    And I should not see any tags

  Scenario: Edit post tags
    Given there is a post titled "Original Post" with tags "ruby, rails"
    And I am on the post page
    When I click "Edit"
    And I fill in "Tags" with "ruby, rails, updated, new-tag"
    And I click "Update Post"
    Then I should see "Post was successfully updated"
    And I should see the tags "ruby", "rails", "updated", "new-tag"

  Scenario: Filter posts by tag
    Given there are posts with the following tags:
      | Title | Tags |
      | Ruby Post | ruby, programming |
      | Rails Post | rails, programming |
      | JavaScript Post | javascript, programming |
    When I select "ruby" from the tag filter
    And I click "Search"
    Then I should see "Ruby Post"
    And I should not see "Rails Post"
    And I should not see "JavaScript Post"

  Scenario: Filter posts by multiple criteria
    Given there are posts with the following tags:
      | Title | Tags |
      | Ruby on Rails | ruby, rails, web |
      | Ruby Programming | ruby, programming |
      | Rails Tutorial | rails, tutorial, web |
    When I fill in the search field with "rails"
    And I select "web" from the tag filter
    And I click "Search"
    Then I should see "Ruby on Rails"
    And I should not see "Ruby Programming"
    And I should not see "Rails Tutorial"

  Scenario: Clear tag filter
    Given I have filtered posts by the "ruby" tag
    And I can see only Ruby-related posts
    When I click "Clear"
    Then I should see all posts
    And the tag filter should be empty

  Scenario: Search posts by tag name
    Given there are posts with the following tags:
      | Title | Tags |
      | Ruby Guide | ruby, guide |
      | Rails Tutorial | rails, tutorial |
      | JavaScript Basics | javascript, basics |
    When I fill in the search field with "ruby"
    And I click "Search"
    Then I should see "Ruby Guide"
    And I should not see "Rails Tutorial"
    And I should not see "JavaScript Basics"

  Scenario: View popular tags
    Given there are posts with the following tag usage:
      | Tag | Usage Count |
      | ruby | 5 |
      | rails | 3 |
      | javascript | 2 |
      | programming | 4 |
    When I am on the forum homepage
    Then I should see popular tags ordered by usage
    And "ruby" should be the most popular tag
    And "programming" should be the second most popular tag

  Scenario: Click on tag to filter posts
    Given there are posts with the following tags:
      | Title | Tags |
      | Ruby Basics | ruby, basics |
      | Rails Advanced | rails, advanced |
      | Ruby on Rails | ruby, rails |
    When I click on the "ruby" tag
    Then I should see "Ruby Basics"
    And I should see "Ruby on Rails"
    And I should not see "Rails Advanced"

  Scenario: Tag normalization
    Given I am on the new post page
    When I fill in "Title" with "Test Post"
    And I fill in "Content" with "Test content"
    And I fill in "Tags" with "  RUBY  ,  Rails  ,  Programming  "
    And I click "Create Post"
    Then I should see "Post was successfully created"
    And the tags should be normalized to "ruby", "rails", "programming"

  Scenario: Handle empty tags
    Given I am on the new post page
    When I fill in "Title" with "Test Post"
    And I fill in "Content" with "Test content"
    And I fill in "Tags" with "ruby, , rails,   , programming"
    And I click "Create Post"
    Then I should see "Post was successfully created"
    And I should only see the tags "ruby", "rails", "programming"

  Scenario: Tag uniqueness
    Given there is already a tag named "ruby"
    When I create a post with the tag "RUBY"
    Then the post should be associated with the existing "ruby" tag
    And there should not be a duplicate "RUBY" tag

  Scenario: Delete post with tags
    Given there is a post titled "Test Post" with tags "ruby, rails"
    And I am on the post page
    When I click "Delete"
    And I confirm the deletion
    Then the post should be deleted
    And the tags should remain in the system
    And I should be redirected to the posts index

  Scenario: Tag display on post show page
    Given there is a post titled "Featured Post" with tags "featured, important, announcement"
    When I visit the post show page
    Then I should see "Featured Post"
    And I should see the tags "featured", "important", "announcement"
    And each tag should be clickable

  Scenario: Tag display on post index page
    Given there are posts with the following tags:
      | Title | Tags |
      | Post 1 | ruby, programming |
      | Post 2 | rails, web |
      | Post 3 | javascript, frontend |
    When I visit the posts index page
    Then I should see all posts
    And each post should display its tags
    And the tags should be clickable

  Scenario: Tag filtering with pagination
    Given there are 25 posts with the "ruby" tag
    And there are 5 posts with the "rails" tag
    When I filter by the "ruby" tag
    Then I should see 10 posts per page
    And I should see pagination controls
    And all visible posts should have the "ruby" tag

  Scenario: Tag case insensitivity
    Given there are posts with tags "Ruby", "Rails", "Programming"
    When I search for "ruby"
    Then I should see posts with the "Ruby" tag
    When I search for "RAILS"
    Then I should see posts with the "Rails" tag

  Scenario: Tag with special characters
    Given I am on the new post page
    When I fill in "Title" with "Special Characters Test"
    And I fill in "Content" with "Testing special characters in tags"
    And I fill in "Tags" with "c++, c#, .net, asp.net"
    And I click "Create Post"
    Then I should see "Post was successfully created"
    And I should see the tags "c++", "c#", ".net", "asp.net"

  Scenario: Long tag names
    Given I am on the new post page
    When I fill in "Title" with "Long Tag Test"
    And I fill in "Content" with "Testing long tag names"
    And I fill in "Tags" with "very-long-tag-name-that-exceeds-normal-length, normal-tag"
    And I click "Create Post"
    Then I should see "Post was successfully created"
    And I should see both tags displayed properly

  Scenario: Tag validation errors
    Given I am on the new post page
    When I fill in "Title" with "Validation Test"
    And I fill in "Content" with "Testing tag validation"
    And I fill in "Tags" with "a" * 256  # Tag name too long
    And I click "Create Post"
    Then I should see a validation error
    And the post should not be created

  Scenario: Tag search with partial matches
    Given there are posts with the following tags:
      | Title | Tags |
      | Ruby Basics | ruby, basics |
      | Ruby on Rails | ruby, rails |
      | JavaScript Guide | javascript, guide |
    When I search for "rub"
    Then I should see "Ruby Basics"
    And I should see "Ruby on Rails"
    And I should not see "JavaScript Guide"

  Scenario: Tag statistics
    Given there are posts with the following tag usage:
      | Tag | Usage Count |
      | ruby | 10 |
      | rails | 8 |
      | javascript | 5 |
    When I visit the forum homepage
    Then I should see tag usage statistics
    And "ruby" should show "10 posts"
    And "rails" should show "8 posts"
    And "javascript" should show "5 posts"
