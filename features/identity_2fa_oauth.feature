Feature: Identity management with 2FA and Google SSO  
  As a Pokémon forum user concerned about security  
  I want to securely register and log into the PokéForum with two-factor auth and Google sign-in  
  So that my account is protected and I can authenticate conveniently

  Background: An existing user account  
    Given a user exists with email "ash@poke.example" and password "pikachu123"

  Scenario: New user registration (happy path)  
    Given I am on the registration page  
    When I sign up with email "misty@poke.example" and password "togepi123"  
    Then I should see a welcome message for "misty@poke.example"  
    And I should be logged in to the forum

  Scenario: Duplicate email registration (sad path)
    Given a user exists with email "brock@poke.example" and password "onyx123"
    When I sign up with email "brock@poke.example" and password "differentpass"
    Then I should see an error "Email has already been taken"
    And my account should not be created