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

  Scenario: Login without 2FA (existing user without 2FA enabled)
    Given a user exists with email "gary@poke.example" and password "eevee123"
    When I log in with email "gary@poke.example" and password "eevee123"
    Then I should be on the forum home page
    And I should see a greeting "Hello, gary@poke.example"

  Scenario: Enable two-factor authentication (happy path setup)
    Given I log in with email "ash@poke.example" and password "pikachu123"
    And I navigate to my account settings
    When I enable two-factor authentication
    Then I should see a QR code for 2FA setup
    And I should see instructions to scan the code with an authenticator app
    When I enter a valid authentication code from my authenticator
    Then I should see a message "Two-factor authentication enabled"
    And 2FA should be active on my account

  Scenario: Enable two-factor authentication with incorrect code (sad path)
    Given I log in with email "ash@poke.example" and password "pikachu123"
    And I navigate to my account settings
    When I enable two-factor authentication
    And I enter an invalid authentication code
    Then I should see an error "Incorrect code. Please try again."
    And 2FA should not be enabled on my account

  Scenario: Login with 2FA enabled but wrong code (sad path)
    Given a user exists with email "ash@poke.example" and password "pikachu123" and 2FA enabled
    When I log in with email "ash@poke.example" and password "pikachu123"
    Then I should be prompted for my 2FA code
    When I enter an invalid authentication code
    Then I should see an error "Invalid two-factor code"
    And I should be returned to the 2FA code prompt (not logged in)

  Scenario: Google OAuth login success (happy path)
    Given I am on the login page
    When I click "Sign in with Google" and approve access
    Then I should be logged in via Google OAuth
    And I should see a welcome message with my Google email