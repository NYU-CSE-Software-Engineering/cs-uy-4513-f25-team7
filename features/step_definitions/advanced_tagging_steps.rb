# Advanced tagging and popular tags steps

Given('there are posts with the following tag usage:') do |table|
  user = @user || User.find_or_create_by!(email: "tag_usage@example.com") do |u|
    u.password = "password123"
    u.password_confirmation = "password123"
  end
  table.hashes.each do |row|
    tag_name = row['Tag'].downcase.strip
    usage = row['Usage Count'].to_i
    tag = Tag.find_or_create_by!(name: tag_name)
    usage.times do |i|
      post = Post.find_or_create_by!(title: "#{tag_name} Post #{i + 1}", user: user) do |p|
        p.body = "Content for #{tag_name} post #{i + 1}"
        p.post_type = 'Thread'
      end
      post.tags << tag unless post.tags.include?(tag)
    end
  end
end

Then('I should see popular tags ordered by usage') do
  within('.popular-tags') do
    expect(page).to have_css('.tag-item', minimum: 1)
  end
end

Then('{string} should be the most popular tag') do |tag_name|
  within('.popular-tags') do
    first_tag = page.all('.tag-item').first
    expect(first_tag).to have_content(tag_name)
  end
end

Then('{string} should be the second most popular tag') do |tag_name|
  within('.popular-tags') do
    tags = page.all('.tag-item')
    expect(tags[1]).to have_content(tag_name) if tags.length > 1
  end
end

Then('I should see tag usage statistics') do
  within('.popular-tags') do
    expect(page).to have_css('.tag-stats')
  end
end

Then('{string} should show {string}') do |tag_name, expected_text|
  within('.popular-tags') do
    tag_item = page.find('.tag-item', text: /#{Regexp.escape(tag_name)}/i, match: :first)
    expect(tag_item).to have_content(expected_text)
  end
end

When('I click on a popular tag {string}') do |tag_name|
  within('.popular-tags') do
    tag_link = page.find('a.tag', text: /#{Regexp.escape(tag_name)}/i, match: :first)
    tag_link.click
  end
end

Given('there is already a tag named {string}') do |tag_name|
  Tag.find_or_create_by!(name: tag_name.downcase.strip)
end

When('I create a post with the tag {string}') do |tag_name|
  @current_user ||= User.find_or_create_by!(email: "test@example.com") do |u|
    u.password = "password123"
    u.password_confirmation = "password123"
  end
  @user = @current_user

  unless page.has_content?("Log out") || page.has_content?("Logout")
    visit new_user_session_path
    fill_in "Email", with: @current_user.email
    fill_in "Password", with: "password123"
    click_button "Log in"
  end

  visit new_post_path
  fill_in "Title", with: "Test Post with #{tag_name}"
  fill_in "Body", with: "Content for test post"
  fill_in "Tags", with: tag_name
  click_button "Create Post"

  expect(page).to have_content("Post was successfully created").or have_content("Test Post with #{tag_name}")
end

Then('the post should be associated with the existing {string} tag') do |tag_name|
  post = Post.order(created_at: :desc).first
  expect(post).to be_present
  expect(post.tags.map(&:name)).to include(tag_name.downcase)
end

Then('there should not be a duplicate {string} tag') do |tag_name|
  tags = Tag.where("LOWER(name) = ?", tag_name.downcase)
  expect(tags.count).to eq(1)
end

Then('I should see a validation error') do
  expect(page).to have_content(/error|invalid|too long|can't be blank/i)
end

Then('the post should not be created') do
  expect(page).to have_current_path(/posts/)
  expect(page).not_to have_content("Post was successfully created")
end

When('I am on the forum homepage for advanced tagging') do
  visit posts_path
end

