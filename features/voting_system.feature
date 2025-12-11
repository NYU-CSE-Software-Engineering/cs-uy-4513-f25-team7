Feature: Post Voting System
  As a forum user
  I want to upvote and downvote posts
  So that I can express my opinion on content quality and help surface the best posts

  Background:
    Given the forum is running
    And I am a registered user
    And I am signed in

  Scenario: Upvote a post
    Given a post titled "Great strategy guide" exists
    When I view the post "Great strategy guide"
    Then I should see a vote score of 0
    When I click the upvote button
    Then I should see a vote score of 1
    And I should see "Upvoted!"

  Scenario: Downvote a post
    Given a post titled "Question about teams" exists
    When I view the post "Question about teams"
    Then I should see a vote score of 0
    When I click the downvote button
    Then I should see a vote score of -1
    And I should see "Downvoted!"

  Scenario: Change vote from upvote to downvote
    Given a post titled "Team composition" exists
    When I view the post "Team composition"
    And I click the upvote button
    Then I should see a vote score of 1
    When I click the downvote button
    Then I should see a vote score of -1
    And I should see "Downvoted!"

  Scenario: Remove vote by clicking same button again
    Given a post titled "Meta discussion" exists
    When I view the post "Meta discussion"
    And I click the upvote button
    Then I should see a vote score of 1
    When I click the upvote button again
    Then I should see a vote score of 0
    And I should see "Vote removed"

  Scenario: View vote score on post index
    Given a post titled "Popular post" exists
    And the post "Popular post" has 3 upvotes
    When I visit the posts index page
    Then I should see "Popular post"
    And I should see a vote score of 3 for "Popular post"

  Scenario: Vote on post from index page
    Given a post titled "New discussion" exists
    When I visit the posts index page
    Then I should see "New discussion"
    And I should see a vote score of 0 for "New discussion"
    When I click the upvote button for "New discussion"
    Then I should see a vote score of 1 for "New discussion"
