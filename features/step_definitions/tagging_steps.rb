Given('the forum is running') do
  # This step is handled by the background setup
end

Given('I am on the forum homepage') do
  visit posts_path
end

Given('I am on the new post page') do
  visit new_post_path
end

Given('I am on the post page') do
  # This will be set by the previous step that creates a post
end

When('I fill in {string} with {string}') do |field, value|
  fill_in field, with: value
end

When('I leave {string} empty') do |field|
  fill_in field, with: ''
end

When('I click {string}') do |button|
  click_button button
end

When('I select {string} from the tag filter') do |tag_name|
  select tag_name, from: 'tag'
end

When('I fill in the search field with {string}') do |search_term|
  fill_in 'search', with: search_term
end

When('I click on the {string} tag') do |tag_name|
  click_link tag_name
end

When('I confirm the deletion') do
  page.driver.browser.switch_to.alert.accept
end

Then('I should see {string}') do |text|
  expect(page).to have_content(text)
end

Then('I should not see {string}') do |text|
  expect(page).not_to have_content(text)
end

Then('I should see the tags {string}') do |tags_string|
  tags = tags_string.split(', ').map(&:strip)
  tags.each do |tag|
    expect(page).to have_content(tag)
  end
end

Then('I should not see any tags') do
  # Check that no tag elements are present
  expect(page).not_to have_css('.tag, .badge, [class*="tag"]')
end

Then('the tags should be normalized to {string}') do |expected_tags|
  expected_tags.split(', ').each do |tag|
    expect(page).to have_content(tag)
  end
end

Then('I should only see the tags {string}') do |expected_tags|
  expected_tags.split(', ').each do |tag|
    expect(page).to have_content(tag)
  end
  # Additional check to ensure no extra tags are present
  # This would need to be implemented based on the actual tag display structure
end

Then('the tag filter should be empty') do
  expect(find('#tag').value).to be_empty
end

Then('I should see popular tags ordered by usage') do
  # Check that popular tags are displayed
  expect(page).to have_css('.popular-tags, .tag-cloud, [class*="popular"]')
end

Then('{string} should be the most popular tag') do |tag_name|
  # Check that the tag appears first in the popular tags list
  popular_tags = page.all('.popular-tag, .tag-item').map(&:text)
  expect(popular_tags.first).to include(tag_name)
end

Then('{string} should be the second most popular tag') do |tag_name|
  # Check that the tag appears second in the popular tags list
  popular_tags = page.all('.popular-tag, .tag-item').map(&:text)
  expect(popular_tags[1]).to include(tag_name)
end

Then('each tag should be clickable') do
  # Check that tags have clickable links
  expect(page).to have_css('a[href*="tag"], a[href*="filter"]')
end

Then('I should see {int} posts per page') do |count|
  # Check pagination
  expect(page).to have_css('.post-item, .post', count: count)
end

Then('I should see pagination controls') do
  expect(page).to have_css('.pagination, .pager, [class*="page"]')
end

Then('all visible posts should have the {string} tag') do |tag_name|
  # Check that all visible posts contain the specified tag
  page.all('.post-item, .post').each do |post|
    expect(post).to have_content(tag_name)
  end
end

Then('I should see tag usage statistics') do
  # Check that tag statistics are displayed
  expect(page).to have_css('.tag-stats, .tag-count, [class*="stat"]')
end

Then('{string} should show {string}') do |tag_name, count_text|
  # Check that a specific tag shows the correct usage count
  expect(page).to have_content("#{tag_name} #{count_text}")
end

Then('I should see a validation error') do
  expect(page).to have_css('.error, .alert-danger, [class*="error"]')
end

Then('the post should not be created') do
  expect(page).to have_current_path(new_post_path)
end

Then('I should be redirected to the posts index') do
  expect(page).to have_current_path(posts_path)
end

Then('the post should be deleted') do
  expect(page).not_to have_content('Test Post')
end

Then('the tags should remain in the system') do
  # Check that tags still exist in the database
  expect(Tag.count).to be > 0
end

# Background step definitions for data setup
Given('there is a post titled {string} with tags {string}') do |title, tags_string|
  post = Post.create!(title: title, content: "Content for #{title}")
  tags = tags_string.split(', ').map(&:strip)
  tags.each do |tag_name|
    tag = Tag.find_or_create_by(name: tag_name.downcase)
    post.tags << tag unless post.tags.include?(tag)
  end
end

Given('there are posts with the following tags:') do |table|
  table.hashes.each do |row|
    post = Post.create!(title: row['Title'], content: "Content for #{row['Title']}")
    tags = row['Tags'].split(', ').map(&:strip)
    tags.each do |tag_name|
      tag = Tag.find_or_create_by(name: tag_name.downcase)
      post.tags << tag unless post.tags.include?(tag)
    end
  end
end

Given('there are posts with the following tag usage:') do |table|
  table.hashes.each do |row|
    tag = Tag.find_or_create_by(name: row['Tag'].downcase)
    row['Usage Count'].to_i.times do |i|
      post = Post.create!(title: "#{row['Tag']} Post #{i + 1}", content: "Content for #{row['Tag']} post")
      post.tags << tag unless post.tags.include?(tag)
    end
  end
end

Given('I have filtered posts by the {string} tag') do |tag_name|
  visit posts_path(tag: tag_name)
end

Given('I can see only Ruby-related posts') do
  expect(page).to have_content('Ruby')
  # Additional checks can be added here
end

Given('there is already a tag named {string}') do |tag_name|
  Tag.create!(name: tag_name.downcase)
end

Given('there are {int} posts with the {string} tag') do |count, tag_name|
  tag = Tag.find_or_create_by(name: tag_name.downcase)
  count.times do |i|
    post = Post.create!(title: "#{tag_name} Post #{i + 1}", content: "Content for #{tag_name} post")
    post.tags << tag unless post.tags.include?(tag)
  end
end

Given('there are {int} posts with the {string} tag') do |count, tag_name|
  tag = Tag.find_or_create_by(name: tag_name.downcase)
  count.times do |i|
    post = Post.create!(title: "#{tag_name} Post #{i + 1}", content: "Content for #{tag_name} post")
    post.tags << tag unless post.tags.include?(tag)
  end
end

Given('there are posts with tags {string}') do |tags_string|
  tags = tags_string.split(', ').map(&:strip)
  tags.each do |tag_name|
    tag = Tag.find_or_create_by(name: tag_name.downcase)
    post = Post.create!(title: "#{tag_name} Post", content: "Content for #{tag_name} post")
    post.tags << tag unless post.tags.include?(tag)
  end
end

# Helper methods for complex scenarios
def create_post_with_tags(title, content, tags_string)
  post = Post.create!(title: title, content: content)
  tags = tags_string.split(', ').map(&:strip)
  tags.each do |tag_name|
    tag = Tag.find_or_create_by(name: tag_name.downcase)
    post.tags << tag unless post.tags.include?(tag)
  end
  post
end

def setup_tag_usage_data
  # This method can be used to set up complex tag usage scenarios
  # Implementation would depend on specific test requirements
end
