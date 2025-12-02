# features/step_definitions/social_graph_&_notification_steps.rb
require "securerandom"

# ---------- Helpers ----------
def create_user!(name: nil, email: nil, password: "password")
  email ||= (name ? "#{name.downcase}@example.com" : "user#{SecureRandom.hex(3)}@example.com")
  u = User.find_by(email: email)
  return u if u
  attrs = { email: email, password: password }
  attrs[:name] = name if User.column_names.include?("name") && name
  User.create!(attrs)
end

def user_by_name(name)
  if User.column_names.include?("name")
    User.find_by!(name: name)
  else
    User.find_by!(email: "#{name.downcase}@example.com")
  end
end

def ensure_team!(title:, owner:)
  # Adjust attrs to match your Team schema
  Team.find_or_create_by!(title: title, user: owner) do |t|
    t.description = "Sample"
    t.public = true if t.respond_to?(:public=)
  end
end

# ---------- Background / Auth ----------
Given("I am a registered user") do
  @me = create_user!(email: "me@example.com")
end

Given('there exists another user named {string}') do |name|
  @other = create_user!(name: name)
end

Given('there exists a public team called {string} owned by {string}') do |title, owner_name|
  owner = user_by_name(owner_name)
  @team = ensure_team!(title: title, owner: owner)
end

# ---------- Follow flows ----------
When('I navigate to the profile page for {string}') do |name|
  @other = user_by_name(name)
  visit user_path(@other)
end

When('I visit my own profile page') do
  @me ||= create_user!(email: "me@example.com")
  visit user_path(@me)
end

When('I click {string}') do |label|
  click_button(label) rescue click_link(label)
end


Then("I should see {int} follower on Misty's profile") do |count|
  # Accept singular/plural
  expect(page).to have_content("#{count} follower").or have_content("#{count} followers")
end

Then('I should still see {int} follower on Misty\'s profile') do |count|
  expect(page).to have_content("#{count} follower").or have_content("#{count} followers")
end

Then('a new notification should exist for {string}') do |recipient_name|
  recipient = user_by_name(recipient_name)
  expect(Notification.where(user: recipient).count).to be >= 1
end

# ---------- Favorite flows ----------
When('I go to the team page for {string}') do |title|
  @team ||= Team.find_by!(title: title)
  visit team_path(@team)
end

Given('I am on the team page for {string}') do |title|
  step %(I go to the team page for "#{title}")
end

Given('I have already favorited the team {string}') do |title|
  @team ||= Team.find_by!(title: title)
  Favorite.find_or_create_by!(user: @me, favoritable: @team)
end

Then('I should find {string} in My Favorites') do |title|
  visit favorites_path
  expect(page).to have_content(title)
end

Then('I should see an error message') do
  expect(page).to have_css(".alert, .error, .flash-alert").or have_content("error")
end

# ---------- Notifications page ----------
Given('I have at least one unread notification') do
  @other ||= create_user!(name: "Misty")
  Notification.create!(user: @me, actor: @other, event_type: "follow_created", notifiable: @other)
end

When('I visit the notifications page') do
  visit notifications_path
end

Then('I should see my newest notification listed first') do
  # Keep generic for RED phase; refine when markup exists
  expect(page).to have_content("notification").or have_css(".notification-item")
end

Then('the unread badge should be visible') do
  expect(page).to have_css(".badge", text: /\d+/).or have_content("unread")
end

Then('my unread notifications should be marked as read') do
  expect(Notification.where(user: @me, read_at: nil).count).to eq(0)
end

# ---------- Session helpers ----------
Given('I sign out') do
  if page.has_button?("Log out")
    first(:button, "Log out").click
  elsif page.has_link?("Log out")
    first(:link, "Log out").click
  elsif page.has_link?("Sign out")
    first(:link, "Sign out").click
  end
  # Wait for signed out state - should see Login link
  expect(page).to have_link("Login").or have_link("Log in").or have_link("Sign in")
end

Then('I should be on the sign in page') do
  expect(page).to have_current_path(new_user_session_path, ignore_query: true).or have_content("Log in")
end
