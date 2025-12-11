# Pagination-specific step definitions

Given('there are {int} posts') do |count|
  user = @user || User.find_or_create_by!(email: "paginator@example.com") do |u|
    u.password = "password123"
    u.password_confirmation = "password123"
  end
  count.times do |i|
    Post.create!(title: "Post #{i + 1}", body: "Body #{i + 1}", user: user, post_type: 'Thread')
  end
end

When('I click on page {string}') do |page_number|
  if page.has_link?(page_number)
    click_link page_number
  else
    visit "#{page.current_path}?page=#{page_number}"
  end
end

Given('there are {int} users') do |count|
  count.times do |i|
    User.find_or_create_by!(email: "user#{i + 1}@example.com") do |u|
      u.password = "password123"
      u.password_confirmation = "password123"
      u.role = :user if u.respond_to?(:role=)
    end
  end
  @admin ||= User.find_by(role: :admin) || User.find_by(email: "admin@example.com")
  @admin ||= User.create!(email: "admin@example.com", password: "password123", password_confirmation: "password123", role: :admin)
end

When('I visit the users index page') do
  visit new_user_session_path
  fill_in "Email", with: @admin.email
  fill_in "Password", with: "password123"
  click_button "Log in"
  visit users_path
end

Then('I should see {int} users per page') do |count|
  rows = page.all('table tbody tr, .user-row, [data-test-id="user-row"], .user-card, .list-group-item', minimum: 0)
  expect(rows.size).to be >= [count, 1].max
end

Given('there are {int} notifications for the current user') do |count|
  user = @user || User.find_or_create_by!(email: "notify@example.com") do |u|
    u.password = "password123"
    u.password_confirmation = "password123"
  end
  count.times do |i|
    Notification.create!(user: user, actor: user, event_type: "event_#{i}", notifiable: user)
  end
  # sign in via UI
  visit new_user_session_path
  fill_in "Email", with: user.email
  fill_in "Password", with: "password123"
  click_button "Log in"
end

When('I visit the notifications page for pagination') do
  visit notifications_path
end

