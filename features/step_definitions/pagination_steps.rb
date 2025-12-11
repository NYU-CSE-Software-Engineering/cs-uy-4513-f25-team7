# Pagination step definitions - Independent feature

Given('there are {int} posts') do |count|
  user = @user || @current_user || User.find_or_create_by!(email: "pagination_user@example.com") do |u|
    u.password = "password123"
    u.password_confirmation = "password123"
  end
  
  count.times do |i|
    Post.find_or_create_by!(title: "Post #{i + 1}") do |post|
      post.body = "Content for post #{i + 1}"
      post.user = user
      post.post_type = 'Thread'
    end
  end
end

Given('there are {int} users') do |count|
  # Ensure the current user is an admin so they can access the users index
  admin_user = @current_user || @user || User.find_or_create_by!(email: "test@example.com") do |u|
    u.password = "password123"
    u.password_confirmation = "password123"
    u.role = :admin
  end
  admin_user.update!(role: :admin) unless admin_user.admin?
  @current_user = admin_user
  @user = admin_user
  
  # Delete existing pagination test users to ensure clean state
  User.where("email LIKE ?", "pagination_user%@example.com").delete_all
  
  count.times do |i|
    User.find_or_create_by!(email: "pagination_user#{i}@example.com") do |u|
      u.password = "password123"
      u.password_confirmation = "password123"
    end
  end
end

Given('there are {int} notifications for the current user') do |count|
  user = @current_user || @user || User.find_or_create_by!(email: "test@example.com") do |u|
    u.password = "password123"
    u.password_confirmation = "password123"
  end
  
  # Create another user to be the actor
  actor = User.find_or_create_by!(email: "actor@example.com") do |u|
    u.password = "password123"
    u.password_confirmation = "password123"
  end
  
  # Delete existing notifications for this user to avoid conflicts
  Notification.where(user: user).delete_all
  
  count.times do |i|
    Notification.create!(
      user: user,
      actor: actor,
      event_type: "follow_created",
      created_at: Time.current - (count - i).seconds
    )
  end
end

When('I visit the posts index page') do
  visit posts_path
end

When('I visit the users index page') do
  # Ensure current user is an admin to access users index
  user = @current_user || @user
  if user && !user.admin?
    user.update!(role: :admin)
  elsif !user
    user = User.find_or_create_by!(email: "test@example.com") do |u|
      u.password = "password123"
      u.password_confirmation = "password123"
      u.role = :admin
    end
    user.update!(role: :admin) unless user.admin?
    @current_user = user
    @user = user
  end
  visit users_path
end

When('I visit the notifications page for pagination') do
  visit notifications_path
end

When('I click on page {string}') do |page_num|
  # Look for pagination link with the page number within pagination container
  within('.pagination', wait: 2) do
    # Find the link that contains the page number and is specifically a pagination link
    # Use first match to avoid ambiguity
    link = first("a[href*='page=#{page_num}']", wait: 2)
    if link.nil?
      # Try finding by text content
      link = first("a", text: page_num, wait: 2)
    end
    link.click if link
  end
rescue Capybara::ElementNotFound
  # Try alternative selector - look for link with page parameter, use first
  first("a[href*='page=#{page_num}']", wait: 2).click
end

Then('I should see {int} posts per page') do |count|
  # Wait for posts to load
  expect(page).to have_css('.post-card, .post', wait: 5)
  
  # Count post cards, excluding pagination elements
  post_cards = page.all('.post-card', wait: 2)
  if post_cards.empty?
    post_cards = page.all('.post', wait: 2)
  end
  
  # Filter to only actual post cards (those with titles)
  actual_count = post_cards.count { |card| 
    card.has_css?('.post-title, h3, [class*="title"]', wait: 1) rescue false
  }
  
  expect(actual_count).to eq(count), "Expected #{count} posts, but found #{actual_count}. Page content: #{page.text[0..200]}"
end

Then('I should see {int} users per page') do |count|
  # Count table rows, excluding header
  # Only count rows that have pagination_user emails (our test users)
  rows = page.all('table tbody tr', wait: 2)
  # Filter to only pagination test users
  pagination_rows = rows.select { |row| row.text.match?(/pagination_user\d+@example\.com/) }
  actual_count = pagination_rows.count > 0 ? pagination_rows.count : rows.count
  expect(actual_count).to eq(count), "Expected #{count} users, but found #{actual_count}. Rows: #{rows.count}, Pagination rows: #{pagination_rows.count}"
end

Then('I should see {int} notifications per page') do |count|
  # Wait for notifications to load
  expect(page).to have_css('.notification-item, li.notification-item, .notification-list li', wait: 5)
  
  # Count notification items - try multiple selectors
  notifications = page.all('.notification-item', wait: 2)
  if notifications.empty?
    notifications = page.all('li.notification-item', wait: 2)
  end
  if notifications.empty?
    notifications = page.all('.notification-list li', wait: 2)
  end
  
  actual_count = notifications.count
  expect(actual_count).to eq(count), "Expected #{count} notifications, but found #{actual_count}. Page content: #{page.text[0..500]}"
end

Then('I should see pagination controls') do
  expect(page).to have_css('.pagination')
end

Then('I should not see pagination controls') do
  expect(page).not_to have_css('.pagination')
end

Then('I should be on page {int}') do |page_num|
  # Check URL contains page parameter
  expect(page.current_url).to include("page=#{page_num}")
end

Then('I should see {int} posts') do |count|
  post_cards = page.all('.post-card', wait: 2)
  if post_cards.empty?
    post_cards = page.all('.post', wait: 2)
  end
  actual_count = post_cards.count { |card| 
    card.has_css?('.post-title, h3, [class*="title"]')
  }
  expect(actual_count).to eq(count)
end
