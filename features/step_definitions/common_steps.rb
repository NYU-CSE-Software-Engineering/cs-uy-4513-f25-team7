# Shared step definitions used across multiple features
# This prevents ambiguous step definition errors

Given('the forum is running') do
  # Placeholder to indicate app is up; nothing to do for in-process tests
end

Then('I should see {string}') do |text|
  expect(page).to have_content(text)
end

Then("I should not see {string}") do |text|
  expect(page).not_to have_content(text)
end

When('I visit the posts index page') do
  visit posts_path
end

Given('I am a registered user') do
  @current_user ||= User.find_or_create_by!(email: "test@example.com") do |u|
    u.password = "password123"
    u.password_confirmation = "password123"
  end
  @user = @current_user
end

When("I press {string}") do |text|
  # Try button first
  if page.has_button?(text, wait: 2)
    click_button text
  # Try link
  elsif page.has_link?(text, wait: 2)
    click_link text
  # Try link with partial text match
  elsif page.has_link?(/.*#{Regexp.escape(text)}.*/i, wait: 2)
    click_link /.*#{Regexp.escape(text)}.*/i
  else
    # Last resort: try to find any clickable element with the text
    element = page.find(:button, text, match: :first, wait: 2) rescue nil
    element ||= page.find(:link, text, match: :first, wait: 2) rescue nil
    element ||= page.find("a, button", text: /#{Regexp.escape(text)}/i, match: :first, wait: 2)
    element.click
  end
end

