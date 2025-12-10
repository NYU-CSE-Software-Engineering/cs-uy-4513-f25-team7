Feature: Direct messages between members
  As a signed-in member
  I want to send direct messages to other members
  So that we can coordinate battles and trades privately

  Background:
    Given I am signed in
    And there exists another user named "Misty"

  @happy
  Scenario: Send a direct message from a profile page
    When I navigate to the profile page for "Misty"
    And I press "Send Message"
    And I fill in "Subject" with "Battle tonight?"
    And I fill in "Body" with "Want to battle at 8pm on Showdown?"
    And I press "Send Message"
    Then I should see "Message sent."
    And I should see "Battle tonight?"

  @happy
  Scenario: See received messages in my inbox
    Given the user "Misty" has sent me a message "Trade request"
    When I visit the messages inbox
    Then I should see "Trade request"

  @sad
  Scenario: Must be signed in to access messages
    Given I sign out for social notifications
    When I visit the messages inbox
    Then I should be on the sign in page
    And I should see "Please sign in to continue"
