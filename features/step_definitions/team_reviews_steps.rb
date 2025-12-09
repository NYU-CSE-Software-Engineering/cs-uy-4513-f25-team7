# features/step_definitions/team_reviews_steps.rb
require 'capybara/rails'

# ------- Given Steps -------

Given("a published public team {string} exists owned by {string}") do |team_name, owner_email|
  owner = User.find_by!(email: owner_email)
  Team.find_or_create_by!(name: team_name, user: owner) do |t|
    t.status = :published
    t.visibility = :public_team
  end
end

Given("a moderator exists with email {string} and password {string}") do |email, password|
  User.find_or_create_by!(email: email) do |u|
    u.password = password
    u.password_confirmation = password
    u.role = :moderator
  end
end

Given("I am logged in as {string} with password {string}") do |email, password|
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

Given(/^I have already reviewed "([^"]*)" with (\d+) stars? and body "([^"]*)"$/) do |team_name, rating, body|
  team = Team.find_by!(name: team_name)
  user = User.find_by!(email: @current_email)
  Review.find_or_create_by!(team: team, user: user) do |r|
    r.rating = rating
    r.body = body
  end
end

Given("the team {string} has the following reviews:") do |team_name, table|
  team = Team.find_by!(name: team_name)
  
  table.hashes.each do |row|
    # Create user if doesn't exist
    user = User.find_or_create_by!(email: row["user"]) do |u|
      u.password = "password123"
      u.password_confirmation = "password123"
    end
    
    Review.create!(
      team: team,
      user: user,
      rating: row["rating"].to_i,
      body: row["body"]
    )
  end
end

# ------- When Steps -------

When("I visit the team page for {string}") do |team_name|
  team = Team.find_by!(name: team_name)
  visit team_path(team)
end

When("I select a rating of {int} stars") do |rating|
  choose "rating_#{rating}"
end

When("I fill in the review body with {string}") do |body|
  fill_in "Review", with: body
end

# Note: "I click {string}" is defined in social_graph_notifications_steps.rb

When("I log out") do
  if page.has_link?("Log out")
    click_link "Log out"
  elsif page.has_button?("Log out")
    click_button "Log out"
  elsif page.has_link?("Logout")
    click_link "Logout"
  else
    visit destroy_user_session_path
  end
end

# ------- Then Steps -------
# Note: "I should see {string}" and "I should not see {string}" are defined in common_steps.rb

Then("I should see {string} reviews") do |count|
  expect(page).to have_content("#{count} review")
end

