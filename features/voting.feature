Feature: Post Voting System
  As a forum user
  I want to upvote and downvote posts
  So that I can express my opinion on content quality

  Background:
    Given I am a registered user
    And I am signed in

  Scenario: Upvote a post
    Given a post titled "Great Strategy Guide" exists
    When I view the post "Great Strategy Guide"
    And I click the upvote button
    Then I should see a vote score of 1

  Scenario: Downvote a post
    Given a post titled "Questionable Advice" exists
    When I view the post "Questionable Advice"
    And I click the downvote button
    Then I should see a vote score of -1

  Scenario: Change vote from upvote to downvote
    Given a post titled "Test Post" exists
    And the post "Test Post" has 1 upvotes
    When I view the post "Test Post"
    And I should see a vote score of 1
    When I click the downvote button
    Then I should see a vote score of -1

  Scenario: Remove vote by clicking same button again
    Given a post titled "Vote Test Post" exists
    When I view the post "Vote Test Post"
    And I click the upvote button
    Then I should see a vote score of 1
    When I click the upvote button again
    Then I should see a vote score of 0

  Scenario: View vote score on post index page
    Given a post titled "Popular Post" exists
    And the post "Popular Post" has 5 upvotes
    When I visit the posts index page
    Then I should see a vote score of 5 for "Popular Post"

  Scenario: Vote on post from index page
    Given a post titled "Index Page Post" exists
    When I visit the posts index page
    And I click the upvote button for "Index Page Post"
    Then I should see a vote score of 1 for "Index Page Post"



