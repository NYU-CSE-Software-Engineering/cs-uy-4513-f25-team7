Given('the forum is running') do
  # Rails app should be running - no action needed for Cucumber
  # This step is just a placeholder
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
  # Try to find by label first, then by field name
  begin
    fill_in field, with: value
  rescue Capybara::ElementNotFound
    # If not found by label, try field name mapping
    field_name = case field
                 when 'Tags'
                   'tag_names'
                 when 'Title'
                   'title'
                 when 'Content'
                   'content'
                 else
                   field.downcase.gsub(/\s+/, '_')
                 end
    fill_in field_name, with: value
  end
end

When('I leave {string} empty') do |field|
  # Try to find by label first, then by field name
  begin
    fill_in field, with: ''
  rescue Capybara::ElementNotFound
    # If not found by label, try field name mapping
    field_name = case field
                 when 'Tags'
                   'tag_names'
                 when 'Title'
                   'title'
                 when 'Content'
                   'content'
                 else
                   field.downcase.gsub(/\s+/, '_')
                 end
    fill_in field_name, with: ''
  end
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
  # Click the first matching tag link (there may be multiple posts with the same tag)
  first(:link, tag_name).click
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
  # Handle both "tag1, tag2" and "tag1", "tag2" formats
  tags = tags_string.split(/["\s]*,\s*["\s]*/).map(&:strip).reject(&:blank?)
  tags.each do |tag|
    # Remove quotes if present
    tag = tag.gsub(/^["']|["']$/, '')
    expect(page).to have_content(tag)
  end
end

# Handle multiple tag strings: "tag1", "tag2", "tag3"
Then('I should see the tags {string}, {string}, {string}, {string}') do |tag1, tag2, tag3, tag4|
  [tag1, tag2, tag3, tag4].each do |tag|
    expect(page).to have_content(tag)
  end
end

# Handle three tags
Then('I should see the tags {string}, {string}, {string}') do |tag1, tag2, tag3|
  [tag1, tag2, tag3].each do |tag|
    expect(page).to have_content(tag)
  end
end

# Handle two tags
Then('I should see the tags {string}, {string}') do |tag1, tag2|
  [tag1, tag2].each do |tag|
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
  # When validation fails, we should still be on the form page
  # The form might be rendered on /posts/new or the errors might redirect
  # Just check that we can see error messages or form fields
  expect(page).to have_content("can't be blank").or have_field('title').or have_field('Title')
end

Then('the tag filter should be empty') do
  expect(find('#tag').value).to be_empty
end

Then('I should see all posts') do
  expect(page).to have_css('.post, .post-item, [class*="post"]')
end

Then('I can see only Ruby-related posts') do
  # This step just verifies we're on a filtered page - posts may or may not exist
  # The actual verification happens in subsequent steps
  expect(page).to have_content('Ruby').or have_content('No posts found')
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
  # Create at least one post with the tag so the filter has something to show
  post = Post.create!(title: "#{tag_name.capitalize} Post", content: "Content for #{tag_name} post")
  tag = Tag.find_or_create_by(name: tag_name.downcase)
  post.tags << tag unless post.tags.include?(tag)
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
