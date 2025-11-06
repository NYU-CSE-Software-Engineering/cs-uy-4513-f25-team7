Feature: Account lockout on repeated failed logins
  As a security-conscious member
  I want my account to lock after several failed login attempts
  So that brute-force password guessing is deterred

  Background:
    Given a user exists with email "may@poke.example" and password "securePass12"

  Scenario: Lock the account after 5 failed attempts and show lock message
    When I attempt to log in with email "may@poke.example" and password "wrong1"
    And I attempt to log in with email "may@poke.example" and password "wrong2"
    And I attempt to log in with email "may@poke.example" and password "wrong3"
    And I attempt to log in with email "may@poke.example" and password "wrong4"
    And I attempt to log in with email "may@poke.example" and password "wrong5"
    Then I should see an error "Your account is locked for 15 minutes."
    And I should remain on the login page not logged in

    When I attempt to log in with email "may@poke.example" and password "securePass12"
    Then I should see an error "Your account is locked for 15 minutes."
    And I should remain on the login page not logged in
