# features/step_definitions/role_steps.rb
# Step Definitions — Role Assignment (Moderation Controls)

Given("the following users exist:") do |table|
  table.hashes.each do |row|
    User.find_or_create_by!(email: row["email"]) do |u|
      u.password = "password123"
      u.role = row["role"]
    end
  end
end

Given("I am signed in as {string}") do |email|
  visit new_user_session_path
  fill_in "Email", with: email
  fill_in "Password", with: "password123"
  click_button "Log in"
end

Given("I am signed in as a moderator") do
  moderator = User.find_or_create_by!(email: "mod@poke.com") do |u|
    u.password = "password123"
    u.role = "moderator"
  end

  visit new_user_session_path
  fill_in "Email", with: moderator.email
  fill_in "Password", with: "password123"
  click_button "Log in"
end

Given("I am on the Role Management page") do
  visit users_path
  expect(page).to have_content("Role Management").or have_button("Promote")
end

When(/^I click "([^"]*)" for "([^"]*)"$/) do |button_text, email|
  within(:xpath, "//tr[td[contains(.,'#{email}')]]") do
    click_button button_text
  end
end

When("I visit the Role Management page") do
  visit users_path
end

Then(/^I should see "([^"]*)"$/) do |text|
  expect(page).to have_content(text)
end

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
