# Voting system step definitions
# Note: "a post titled {string} exists" and "I view the post {string}" are defined in forum_steps.rb

Then('I should see a vote score of {int}') do |expected_score|
  # Wait for the page to load and find the vote score element
  expect(page).to have_css('.vote-score', wait: 5)
  score_element = page.find('.vote-score')
  actual_score = score_element.text.to_i
  expect(actual_score).to eq(expected_score)
end

When('I click the upvote button') do
  # Find the upvote form and submit it
  # For AJAX forms in tests, we need to submit the form directly
  within('.post-voting') do
    form = page.find('form.vote-form', match: :first)
    # Submit the form directly (works for both AJAX and regular forms)
    form.submit
  end
  # Wait for request to complete
  sleep(1)
  # Reload the page to see updated vote score and flash message
  visit page.current_path
end

When('I click the downvote button') do
  # Find the downvote form and submit it
  within('.post-voting') do
    # Find the form with downvote button
    form = page.all('form.vote-form').find { |f| f.has_css?('.downvote-btn') }
    form.submit
  end
  # Wait for request to complete
  sleep(1)
  # Reload the page to see updated vote score and flash message
  visit page.current_path
end

When('I click the upvote button again') do
  # Same as clicking upvote button - it will toggle
  within('.post-voting') do
    form = page.find('form.vote-form', match: :first)
    form.submit
  end
  # Wait for request to complete
  sleep(1)
  # Reload the page to see updated vote score and flash message
  visit page.current_path
end

Given('the post {string} has {int} upvotes') do |title, count|
  post = Post.find_by!(title: title)
  # Clear existing votes for this post
  post.votes.destroy_all
  # Create the specified number of upvotes
  count.times do |i|
    post.votes.create!(value: 1, ip_address: "127.0.0.#{i + 1}")
  end
  post.reload
end

When('I visit the posts index page') do
  visit posts_path
end

Then('I should see a vote score of {int} for {string}') do |expected_score, title|
  post = Post.find_by!(title: title)
  # Find the post card and check its vote score
  within(".post-card", text: title) do
    score_element = page.find('.vote-score')
    actual_score = score_element.text.to_i
    expect(actual_score).to eq(expected_score)
  end
end

When('I click the upvote button for {string}') do |title|
  post = Post.find_by!(title: title)
  # Find the specific post's voting section
  within(".post-card", text: title) do
    form = page.find('form.vote-form', match: :first)
    form.submit
  end
  # Wait for request to complete
  sleep(1)
  # Reload the page to see updated vote score and flash message
  visit page.current_path
end

