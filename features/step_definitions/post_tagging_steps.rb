Given('the forum is running') do
  # rails app should be running
end

Given('I am on the forum homepage') do
  visit posts_path
end

Given('I am on the new post page') do
  visit new_post_path
end

Given('I am on the posts index page') do
  visit posts_path
end

When('I fill in {string} with {string}') do |field, value|
  fill_in field, with: value
end

When('I leave {string} empty') do |field|
  fill_in field, with: ''
end

When('I press {string}') do |button|
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

When('I click {string}') do |link_text|
  click_link link_text
end

Then('I should be on the post\'s show page') do
  expect(page).to have_css('.post-content, .post-title, [class*="post"]')
end

Then('I should see the message {string}') do |message|
  expect(page).to have_content(message)
end

Then('I should see the title {string}') do |title|
  expect(page).to have_content(title)
end

Then('I should see the tags {string}') do |tags_string|
  tags = tags_string.split(', ').map(&:strip)
  tags.each do |tag|
    expect(page).to have_content(tag)
  end
end

Then('I should not see any tags') do
  expect(page).not_to have_css('.tag, .badge, [class*="tag"]')
end

Then('I should not see {string}') do |content|
  expect(page).not_to have_content(content)
end

Then('I should see {string}') do |content|
  expect(page).to have_content(content)
end

Then('I should see an error message indicating the title is missing') do
  expect(page).to have_content("Title can't be blank")
end

Then('I should see an error message indicating the content is missing') do
  expect(page).to have_content("Content can't be blank")
end

Then('I should still be on the new post page') do
  expect(page).to have_current_path(new_post_path)
end

Then('the tag filter should be empty') do
  expect(find('#tag').value).to be_empty
end

Then('I should see all posts') do
  expect(page).to have_css('.post, .post-item, [class*="post"]')
end

Then('I can see only Ruby-related posts') do
  expect(page).to have_content('Ruby')
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

Given('I have filtered posts by the {string} tag') do |tag_name|
  visit posts_path(tag: tag_name)
end

def create_post_with_tags(title, content, tags_string)
  post = Post.create!(title: title, content: content)
  tags = tags_string.split(', ').map(&:strip)
  tags.each do |tag_name|
    tag = Tag.find_or_create_by(name: tag_name.downcase)
    post.tags << tag unless post.tags.include?(tag)
  end
  post
end
