# features/step_definitions/identity_steps.rb
require 'capybara/rails'
require 'omniauth'
require 'rotp'

# ------- Helpers -------
def totp_code_for(secret)
  ROTP::TOTP.new(secret).now.to_s.rjust(6, '0')
end

def current_user_by_email!
  raise "No current email context set" unless @current_email
  User.find_by!(email: @current_email)
end

def user_2fa_enabled?(user)
  # Support either column name depending on your implementation
  if user.respond_to?(:otp_enabled)
    !!user.otp_enabled
  elsif user.respond_to?(:otp_required_for_login)
    !!user.otp_required_for_login
  else
    false
  end
end

# ------- Hooks -------
Before do
  # Use OmniAuth in test mode so Google OAuth can be mocked safely
  OmniAuth.config.test_mode = true
  OmniAuth.config.mock_auth[:google_oauth2] = nil

  # keep track of the email under test so we can fetch the user record
  @current_email = nil
end

After do
  OmniAuth.config.mock_auth[:google_oauth2] = nil
end

# ------- Given -------
Given("a user exists with email {string} and password {string}") do |email, password|
  User.create!(email: email, password: password, password_confirmation: password)
end

Given("a user exists with email {string} and password {string} and 2FA enabled") do |email, password|
  user = User.create!(email: email, password: password, password_confirmation: password)
  secret = ROTP::Base32.random_base32
  if user.respond_to?(:otp_secret)
    user.update!(otp_secret: secret)
  else
    raise "User model needs an :otp_secret column (string) to store 2FA secret"
  end
  # Mark 2FA enabled depending on your schema
  if user.respond_to?(:otp_enabled)
    user.update!(otp_enabled: true)
  elsif user.respond_to?(:otp_required_for_login)
    user.update!(otp_required_for_login: true)
  else
    raise "User model needs a boolean flag (:otp_enabled or :otp_required_for_login) to mark 2FA active"
  end
end

Given("I am on the registration page") do
  visit new_user_registration_path
end

Given("I am on the login page") do
  visit new_user_session_path
end

# ------- When -------
When("I sign up with email {string} and password {string}") do |email, password|
  @current_email = email
  visit new_user_registration_path
  fill_in "Email", with: email
  fill_in "Password", with: password
  fill_in "Password confirmation", with: password
  # Accept a variety of button texts
  if page.has_button?("Sign up")
    click_button "Sign up"
  else
    click_button(/Sign\s*up|Register/i)
  end
end

When("I log in with email {string} and password {string}") do |email, password|
  @current_email = email
  visit new_user_session_path
  fill_in "Email", with: email
  fill_in "Password", with: password
  if page.has_button?("Log in")
    click_button "Log in"
  else
    click_button(/Log\s*in|Sign\s*in/i)
  end
end

When("I navigate to my account settings") do
  # Adjust if you have a different settings page
  visit edit_user_registration_path
end

When("I enable two-factor authentication") do
  # Your view must have a control to start enrollment
  if page.has_button?("Enable 2FA")
    click_button "Enable 2FA"
  elsif page.has_button?("Enable Two-Factor Authentication")
    click_button "Enable Two-Factor Authentication"
  else
    # Try a generic button
    click_button(/Enable.*(2FA|Two-?Factor)/i)
  end
end

When("I enter a valid authentication code from my authenticator") do
  # This is for the enrollment verification step
  user = current_user_by_email!
  secret =
    if user.respond_to?(:otp_secret) && user.otp_secret.present?
      user.otp_secret
    else
      raise "During 2FA enrollment, store the secret in user.otp_secret so tests can verify"
    end

  fill_in "Authentication code", with: totp_code_for(secret)
  if page.has_button?("Verify code")
    click_button "Verify code"
  else
    click_button(/Verify|Confirm|Submit/i)
  end
end

When("I enter a valid authentication code") do
  # This covers either enrollment verify OR login challenge
  user = current_user_by_email!
  secret =
    if user.respond_to?(:otp_secret) && user.otp_secret.present?
      user.otp_secret
    else
      raise "User has no otp_secret set; cannot generate TOTP in test"
    end

  fill_in "Authentication code", with: totp_code_for(secret)
  if page.has_button?("Verify code")
    click_button "Verify code"
  else
    click_button(/Verify|Confirm|Submit/i)
  end
end

When("I enter an invalid authentication code") do
  fill_in "Authentication code", with: "000000"
  if page.has_button?("Verify code")
    click_button "Verify code"
  else
    click_button(/Verify|Confirm|Submit/i)
  end
end

When("I click {string} and approve access") do |link_text|
  OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
    provider: 'google_oauth2',
    uid: '123545',
    info: { email: 'oak@pokemon.com', name: 'Professor Oak' }
  )
  # The page must contain a link or button to start Google OAuth
  if page.has_link?(link_text)
    click_link link_text
  elsif page.has_button?(link_text)
    click_button link_text
  else
    click_link(/Google|Sign in with Google/i)
  end
  # After callback, the app should sign the user in
  @current_email = "oak@pokemon.com"
end

When("I click {string} and deny the authorization") do |link_text|
  OmniAuth.config.mock_auth[:google_oauth2] = :access_denied
  if page.has_link?(link_text)
    click_link link_text
  elsif page.has_button?(link_text)
    click_button link_text
  else
    click_link(/Google|Sign in with Google/i)
  end
end

# ------- Then -------
Then("I should see a welcome message for {string}") do |email|
  expect(page).to have_content("Welcome, #{email}")
end

Then("I should be logged in to the forum") do
  # Adjust to your app’s post-login content/path
  expect(page).to have_content(/Log out|Logout|Signed in/i)
end

Then("I should see an error {string}") do |error_message|
  expect(page).to have_content(error_message)
end

Then("my account should not be created") do
  # For duplicate email, ensure we didn't add another user with that email
  count = User.where(email: @current_email).count
  expect(count).to be <= 1
end

Then("I should be on the forum home page") do
  # If your root page is the forum home, this is fine; otherwise tweak
  expect(page).to have_content(/Forum Home|Welcome/i).or have_current_path(root_path, ignore_query: true)
end

Then("I should see a greeting {string}") do |greeting|
  expect(page).to have_content(greeting)
end

Then("I should see a QR code for 2FA setup") do
  # Expect an img with alt or content indicating QR; adjust selector if needed
  expect(page).to have_css("img[alt='2FA QR Code']").or have_content(/QR code/i)
end

Then("I should see instructions to scan the code with an authenticator app") do
  expect(page).to have_content(/Scan this QR code with your authenticator app/i)
end

Then("I should see a message {string}") do |message|
  expect(page).to have_content(message)
end

Then("2FA should be active on my account") do
  user = current_user_by_email!
  expect(user_2fa_enabled?(user)).to be true
end

Then("2FA should not be enabled on my account") do
  user = current_user_by_email!
  expect(user_2fa_enabled?(user)).to be false
end

Then("I should be prompted for my 2FA code") do
  expect(page).to have_field("Authentication code").or have_content(/Enter authentication code/i)
end

Then("I should be logged in successfully") do
  expect(page).to have_content(/Log out|Logout|Signed in successfully/i)
end

Then("I should see my forum username or profile") do
  # Simple default: show the email somewhere on the page
  expect(page).to have_content(@current_email)
end

Then(/^I should be returned to the 2FA code prompt(?: \(not logged in\))?$/) do
  expect(page).to have_field("Authentication code")
end

Then("I should be logged in via Google OAuth") do
  expect(page).to have_content(/Logged in with Google|Successfully authenticated from Google/i)
end

Then("I should see a welcome message with my Google email") do
  expect(page).to have_content("oak@pokemon.com")
end

Then("I should remain on the login page not logged in") do
  expect(page).to have_current_path(new_user_session_path, ignore_query: true)
end
