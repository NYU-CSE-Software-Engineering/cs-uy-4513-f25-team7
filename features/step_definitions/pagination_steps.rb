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
  click_link page_number
end

Given('there are {int} users') do |count|
  count.times do |i|
    User.find_or_create_by!(email: "user#{i + 1}@example.com") do |u|
      u.password = "password123"
      u.password_confirmation = "password123"
      u.role = 0 if u.respond_to?(:role=)
    end
  end
end

When('I visit the users index page') do
  visit users_path
end

Then('I should see {int} users per page') do |count|
  rows = page.all('.user-row, [data-test-id="user-row"]', minimum: 0)
  expect(rows.size).to eq(count)
end

Given('there are {int} notifications for the current user') do |count|
  user = @user || User.find_or_create_by!(email: "notify@example.com") do |u|
    u.password = "password123"
    u.password_confirmation = "password123"
  end
  count.times do |i|
    Notification.create!(user: user, actor: user, event_type: "event_#{i}", notifiable: user)
  end
  login_as(user, scope: :user)
end

When('I visit the notifications page for pagination') do
  visit notifications_path
end

