# features/step_definitions/identity_steps.rb
require "omniauth"
require "rotp"
require "active_support/core_ext/numeric/time"
require "identity/lockout_tracker"

Before do
  @users = {}
  @messages = []
  @current_page = :landing
  @session = {
    logged_in: false,
    user_email: nil,
    awaiting_2fa: false,
    pending_user: nil
  }
  @last_account_created = nil
  @displayed_qr = false
  @displayed_instructions = false
  @pending_2fa_enrollment = nil
  @current_user_email = nil
  @visible_profile_identifier = nil
  @lockout_tracker = Identity::LockoutTracker.new(max_attempts: 5, lockout_period: 15.minutes)
end

def create_user(email, password, otp_enabled: false, otp_secret: nil)
  @users[email] = {
    email: email,
    password: password,
    otp_enabled: otp_enabled,
    otp_secret: otp_secret
  }
end

def set_logged_in_user(email)
  @session[:logged_in] = true
  @session[:user_email] = email
  @session[:awaiting_2fa] = false
  @session[:pending_user] = nil
  @current_user_email = email
  @visible_profile_identifier = email
  @lockout_tracker&.record_successful_login(email)
end

def totp_valid?(secret, code)
  ROTP::TOTP.new(secret).verify(code, drift_ahead: 1, drift_behind: 1)
end

def handle_two_factor_enrollment(code)
  secret = @pending_2fa_enrollment[:secret]
  if totp_valid?(secret, code)
    user = @users[@pending_2fa_enrollment[:email]]
    user[:otp_enabled] = true
    user[:otp_secret] = secret
    @messages << "Two-factor authentication enabled"
    @pending_2fa_enrollment = nil
  else
    @messages << "Incorrect code. Please try again."
  end
end

def handle_two_factor_login(code)
  email = @session[:pending_user]
  user = @users[email]
  if user && totp_valid?(user[:otp_secret], code)
    set_logged_in_user(email)
    @current_page = :forum_home
  else
    @messages << "Invalid two-factor code"
    @session[:logged_in] = false
    @session[:awaiting_2fa] = true
    @current_page = :two_factor_prompt
  end
end

def lock_account(email)
  @messages << "Your account is locked for 15 minutes."
  @session[:logged_in] = false
  @session[:awaiting_2fa] = false
  @session[:pending_user] = nil
  @current_page = :login
  @current_user_email = email
end

Given("a user exists with email {string} and password {string}") do |email, password|
  create_user(email, password)
end

Given("a user exists with email {string} and password {string} and 2FA enabled") do |email, password|
  secret = ROTP::Base32.random_base32
  create_user(email, password, otp_enabled: true, otp_secret: secret)
end

Given("I am on the registration page") do
  @current_page = :registration
end

Given("I am on the login page") do
  @current_page = :login
end

When("I sign up with email {string} and password {string}") do |email, password|
  @current_user_email = email
  if @users.key?(email)
    @messages << "Email has already been taken"
    @last_account_created = false
    @session[:logged_in] = false
    @session[:user_email] = nil
    @current_page = :registration
  else
    create_user(email, password)
    @messages << "Welcome, #{email}"
    @last_account_created = true
    set_logged_in_user(email)
    @current_page = :forum_home
  end
end

When("I log in with email {string} and password {string}") do |email, password|
  @current_user_email = email

  if @lockout_tracker.locked?(email)
    lock_account(email)
    next
  end

  user = @users[email]
  if user.nil? || user[:password] != password
    if @lockout_tracker.record_failed_attempt(email)
      lock_account(email)
    else
      @messages << "Invalid email or password"
    end
    @session[:logged_in] = false
    @session[:awaiting_2fa] = false
    @session[:pending_user] = nil
    @current_page = :login
  elsif user[:otp_enabled]
    @messages << "Enter authentication code"
    @session[:logged_in] = false
    @session[:awaiting_2fa] = true
    @session[:pending_user] = email
    @current_page = :two_factor_prompt
  else
    @messages << "Hello, #{email}"
    set_logged_in_user(email)
    @current_page = :forum_home
  end
end

When("I navigate to my account settings") do
  @current_page = :account_settings
end

When("I enable two-factor authentication") do
  raise "User must be logged in to enable 2FA" unless @session[:logged_in] && @session[:user_email]

  secret = ROTP::Base32.random_base32
  @pending_2fa_enrollment = { email: @session[:user_email], secret: secret }
  @displayed_qr = true
  @displayed_instructions = true
  @messages << "Scan this QR code with your authenticator app"
  @current_page = :account_settings
end

When("I enter a valid authentication code from my authenticator") do
  raise "No 2FA enrollment in progress" unless @pending_2fa_enrollment

  code = totp_code_for(@pending_2fa_enrollment[:secret])
  handle_two_factor_enrollment(code)
end

When("I enter a valid authentication code") do
  if @pending_2fa_enrollment
    code = totp_code_for(@pending_2fa_enrollment[:secret])
    handle_two_factor_enrollment(code)
  elsif @session[:awaiting_2fa] && @session[:pending_user]
    user = @users[@session[:pending_user]]
    code = totp_code_for(user[:otp_secret])
    handle_two_factor_login(code)
  else
    raise "No pending 2FA action"
  end
end

When("I enter an invalid authentication code") do
  if @pending_2fa_enrollment
    handle_two_factor_enrollment("000000")
  elsif @session[:awaiting_2fa] && @session[:pending_user]
    handle_two_factor_login("000000")
  else
    raise "No pending 2FA action"
  end
end

When("I click {string} and approve access") do |_oauth_link_text|
  OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
    provider: 'google_oauth2',
    uid: '123545',
    info: { email: 'oak@pokemon.com', name: 'Professor Oak' }
  )

  auth = OmniAuth.config.mock_auth[:google_oauth2]
  email = auth.info.email
  @messages << "Welcome, #{email}"
  @messages << "Logged in with Google"
  set_logged_in_user(email)
  @current_page = :forum_home
end

When("I click {string} and deny the authorization") do |_oauth_link_text|
  OmniAuth.config.mock_auth[:google_oauth2] = :access_denied
  @messages << "Google sign-in failed or was canceled"
  @session[:logged_in] = false
  @session[:user_email] = nil
  @current_page = :login
end

Then("I should see a welcome message for {string}") do |email|
  expect(@messages).to include("Welcome, #{email}")
end

Then("I should be logged in to the forum") do
  expect(@session[:logged_in]).to be true
  expect(@current_page).to eq(:forum_home)
end

Then("I should see an error {string}") do |error_message|
  expect(@messages).to include(error_message)
end

Then("my account should not be created") do
  expect(@last_account_created).to be(false)
  expect(@session[:logged_in]).to be false
  expect(@current_page).to eq(:registration)
end

Then("I should be on the forum home page") do
  expect(@current_page).to eq(:forum_home)
end

Then("I should see a greeting {string}") do |greeting|
  expect(@messages).to include(greeting)
end

Then("I should see a QR code for 2FA setup") do
  expect(@displayed_qr).to be true
end

Then("I should see instructions to scan the code with an authenticator app") do
  expect(@displayed_instructions).to be true
  expect(@messages).to include("Scan this QR code with your authenticator app")
end

Then("I should see a message {string}") do |message|
  expect(@messages).to include(message)
end

Then("2FA should be active on my account") do
  user = @users[@current_user_email] || @users[@session[:user_email]]
  expect(user && user[:otp_enabled]).to be true
end

Then("2FA should not be enabled on my account") do
  user = @users[@current_user_email] || @users[@session[:user_email]]
  expect(user && user[:otp_enabled]).to be false
end

Then("I should be prompted for my 2FA code") do
  expect(@session[:awaiting_2fa]).to be true
  expect(@current_page).to eq(:two_factor_prompt)
  expect(@messages).to include("Enter authentication code")
end

Then("I should be logged in successfully") do
  expect(@session[:logged_in]).to be true
  expect(@current_page).to eq(:forum_home)
end

Then("I should see my forum username or profile") do
  expect(@visible_profile_identifier).to eq(@current_user_email)
end

Then(/^I should be returned to the 2FA code prompt(?: \(not logged in\))?$/) do
  expect(@session[:awaiting_2fa]).to be true
  expect(@current_page).to eq(:two_factor_prompt)
end

Then("I should be logged in via Google OAuth") do
  expect(@session[:logged_in]).to be true
  expect(@current_page).to eq(:forum_home)
  expect(@messages).to include("Logged in with Google")
end

Then("I should see a welcome message with my Google email") do
  expect(@messages).to include("Welcome, oak@pokemon.com")
end

Then("I should remain on the login page not logged in") do
  expect(@session[:logged_in]).to be false
  expect(@current_page).to eq(:login)
end

# Add this one for TDD Assignment
When("I attempt to log in with email {string} and password {string}") do |email, password|
  step %{I log in with email "#{email}" and password "#{password}"}
end
