# Shared step definitions used across multiple features
# This prevents ambiguous step definition errors

Then('I should see {string}') do |text|
  expect(page).to have_content(text)
end

Then("I should not see {string}") do |text|
  expect(page).not_to have_content(text)
end

Given('I am a registered user') do
  @current_user ||= User.find_or_create_by!(email: "test@example.com") do |u|
    u.password = "password123"
    u.password_confirmation = "password123"
  end
  @user = @current_user
end

When("I press {string}") do |text|
  if page.has_button?(text)
    click_button text
  else
    click_link text
  end
end

