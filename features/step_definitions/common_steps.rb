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

# Pagination helpers (used by pagination.feature)
Then('I should be on page {int}') do |int|
  expect(page).to have_current_path(/page=#{int}/)
end

Then('I should see {int} posts') do |int|
  posts = page.all('.post-card, .post, [class*="post-card"]', minimum: 0)
  expect(posts.size).to eq(int)
end

Then('I should see {int} notifications per page') do |int|
  rows = page.all('[data-test-id="notification-row"], .notification-row', minimum: 0)
  expect(rows.size).to eq(int)
end

Then('I should not see pagination controls') do
  expect(page).not_to have_css('.pagination, .pagination-wrapper, [class*="pagination"]')
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
  if page.has_button?(text)
    click_button text
  else
    click_link text
  end
end

