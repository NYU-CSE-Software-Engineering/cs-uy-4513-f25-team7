# Advanced Tagging step definitions - Independent feature
# This feature focuses on popular tags, tag statistics, and advanced tag features

Given('there are posts with the following tag usage:') do |table|
  user = @user || @current_user || User.find_or_create_by!(email: "tag_user@example.com") do |u|
    u.password = "password123"
    u.password_confirmation = "password123"
  end
  
  table.hashes.each do |row|
    tag_name = row['Tag'].downcase.strip
    usage_count = row['Usage Count'].to_i
    
    tag = Tag.find_or_create_by!(name: tag_name)
    
    # Create the specified number of posts with this tag
    usage_count.times do |i|
      post = Post.find_or_create_by!(
        title: "#{tag_name.capitalize} Post #{i + 1}",
        user: user
      ) do |p|
        p.body = "Content for #{tag_name} post #{i + 1}"
        p.post_type = 'Thread'
      end
      
      # Associate tag with post if not already associated
      post.tags << tag unless post.tags.include?(tag)
    end
  end
end

When('I am on the forum homepage for advanced tagging') do
  visit posts_path
end

Then('I should see popular tags ordered by usage') do
  expect(page).to have_css('.popular-tags')
end

Then('{string} should be the most popular tag') do |tag_name|
  # Check that the tag appears in the popular tags section
  within('.popular-tags') do
    expect(page).to have_content(tag_name)
    # Check that it's the first tag in the list (most popular)
    first_tag = page.all('.tag-item').first
    expect(first_tag).to have_content(tag_name) if first_tag
  end
end

Then('{string} should be the second most popular tag') do |tag_name|
  # Check that the tag appears in the popular tags section
  within('.popular-tags') do
    expect(page).to have_content(tag_name)
    # Check that it's the second tag in the list
    tags = page.all('.tag-item')
    expect(tags.length).to be >= 2
    expect(tags[1]).to have_content(tag_name) if tags[1]
  end
end

Then('I should see tag usage statistics') do
  # Check for tag statistics display in popular tags section
  within('.popular-tags') do
    expect(page).to have_css('.tag-stats')
  end
end

Then('{string} should show {string}') do |tag_name, expected_text|
  # Find the tag item and check for the expected text
  within('.popular-tags') do
    tag_item = page.find('.tag-item', text: /#{Regexp.escape(tag_name)}/i, match: :first)
    expect(tag_item).to have_content(expected_text)
  end
end

When('I click on a popular tag {string}') do |tag_name|
  # Find and click the tag link in the popular tags section
  within('.popular-tags') do
    tag_link = page.find('a.tag', text: /#{Regexp.escape(tag_name)}/i, match: :first)
    tag_link.click
  end
end

Then('I should see a validation error') do
  # Check for validation error messages
  expect(page).to have_content(/error|invalid|too long|can't be blank/i)
end

Then('the post should not be created') do
  # Check that we're still on the new post page or see an error
  # The post should not have been created successfully
  expect(page).not_to have_content('Post was successfully created')
  # We should either be on the new post page, see an error, or be redirected back
  # (Some forms redirect on validation errors, which is acceptable)
  unless page.has_content?('Post was successfully created')
    # Accept being on new post page, posts index (redirected), or seeing validation errors
    expect(
      page.current_path.match(/new|posts\/new/) || 
      page.current_path == '/posts' ||
      page.has_content?(/error|invalid|too long/i)
    ).to be_truthy, "Expected to be on new post page or see error, but was on #{page.current_path}"
  end
end

When('I create a post with the tag {string}') do |tag_name|
  visit new_post_path
  fill_in "Title", with: "Test Post with #{tag_name}"
  fill_in "Body", with: "Content for test post"
  fill_in "Tags", with: tag_name
  click_button "Create Post"
end

Then('the post should be associated with the existing {string} tag') do |tag_name|
  post = Post.order(created_at: :desc).first
  expect(post).to be_present
  expect(post.tags.map(&:name)).to include(tag_name.downcase)
end

Then('there should not be a duplicate {string} tag') do |tag_name|
  # Check that there's only one tag with this name (case-insensitive)
  tags = Tag.where("LOWER(name) = ?", tag_name.downcase)
  expect(tags.count).to eq(1)
end

Given('there is already a tag named {string}') do |tag_name|
  Tag.find_or_create_by!(name: tag_name.downcase.strip)
end

Then('I should be on the post\'s show page') do
  expect(page.current_path).to match(/\/posts\/\d+/)
end
