# features/step_definitions/role_steps.rb
# Step Definitions — Role Assignment (Moderation Controls)

Given("the following users exist:") do |table|
  table.hashes.each do |row|
    email = row.fetch("email")
    role  = row["role"].presence || "user"  # default to "user" if missing

    user = User.find_or_initialize_by(email: email)
    user.password              = "password123"
    user.password_confirmation = "password123"
    user.role                  = role       # "user", "moderator", or "admin"
    user.save!
  end
end


Given("I am signed in as {string}") do |email|
  visit new_user_session_path
  fill_in "Email", with: email
  fill_in "Password", with: "password123"
  click_button "Log in"
end

Given("I am signed in as a moderator") do
  # Clean out any bad/old moderator rows first
  User.where(email: "mod@poke.com").delete_all

  # Create a fresh moderator WITH a non-null role
  moderator = User.create!(
    email: "mod@poke.com",
    password: "password123",
    password_confirmation: "password123",
    role: "moderator"
  )

  # Reuse your existing generic sign-in step
  step 'I am signed in as "mod@poke.com"'
end




Given("I am on the Role Management page") do
  visit users_path
  expect(page).to have_content("Role Management").or have_button("Promote")
end

When(/^I click "([^"]*)" for "([^"]*)"$/) do |action, email|
  # Reload the Role Management page so it sees any newly-created users
  visit users_path

  row = find(:xpath, "//tr[td[contains(.,'#{email}')]]")
  row.click_button(action)
end

When("I visit the Role Management page") do
  visit users_path
end

# Then(/^I should see "([^"]*)"$/) do |text|
#   expect(page).to have_content(text)
# end

Then("I should not see any {string} or {string} buttons") do |btn1, btn2|
  expect(page).not_to have_button(btn1)
  expect(page).not_to have_button(btn2)
end

Then("{string} should appear in the list with role {string}") do |email, role|
  within(:xpath, "//tr[td[contains(.,'#{email}')]]") do
    expect(page).to have_content(role)
  end
end

Then("{string} should remain listed as a moderator") do |email|
  within(:xpath, "//tr[td[contains(.,'#{email}')]]") do
    expect(page).to have_content("Moderator")
  end
end

Then("I should see a success banner {string}") do |msg|
  expect(page).to have_css(".alert-success", text: msg)
end

Then("I should see an error banner {string}") do |msg|
  expect(page).to have_css(".alert-danger", text: msg)
end

Given("I am on the Role Management page") do
  visit users_path
end

When("I visit the Role Management page directly") do
  visit users_path
end


