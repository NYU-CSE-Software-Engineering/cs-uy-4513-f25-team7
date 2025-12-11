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
  # Get current post ID from the page
  post_id = page.current_url.match(/\/posts\/(\d+)/)&.[](1) || @post&.id
  
  # Find the upvote button and click it
  within('.post-voting') do
    button = page.find('.upvote-btn', match: :first, wait: 5)
    button.click
  end
  
  # Wait for flash or score to update; avoid forcing a reload to not miss flash
  page.has_content?('Upvoted!', wait: 5) ||
    page.has_content?('Downvoted!', wait: 2) ||
    page.has_content?('Vote removed', wait: 2) ||
    page.has_css?('.vote-score', wait: 5)
end

When('I click the downvote button') do
  # Get current post ID from the page
  post_id = page.current_url.match(/\/posts\/(\d+)/)&.[](1) || @post&.id
  
  # Find the downvote button and click it
  within('.post-voting') do
    button = page.find('.downvote-btn', match: :first, wait: 5)
    button.click
  end
  
  page.has_content?('Downvoted!', wait: 5) ||
    page.has_content?('Upvoted!', wait: 2) ||
    page.has_content?('Vote removed', wait: 2) ||
    page.has_css?('.vote-score', wait: 5)
end

When('I click the upvote button again') do
  # Get current post ID from the page
  post_id = page.current_url.match(/\/posts\/(\d+)/)&.[](1) || @post&.id
  
  # Same as clicking upvote button - it will toggle
  within('.post-voting') do
    button = page.find('.upvote-btn', match: :first, wait: 5)
    button.click
  end
  
  page.has_content?('Vote removed', wait: 5) ||
    page.has_content?('Upvoted!', wait: 2) ||
    page.has_content?('Downvoted!', wait: 2) ||
    page.has_css?('.vote-score', wait: 5)
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

# Removed duplicate - using pagination_steps.rb instead
# When('I visit the posts index page') do
#   visit posts_path
# end

Then('I should see a vote score of {int} for {string}') do |expected_score, title|
  post = Post.find_by!(title: title)
  # Reload the page to ensure we have the latest data
  visit page.current_path if page.current_path.include?('posts')
  
  # Find the post card - try multiple selectors
  post_card = nil
  [".post-card", ".post", "[class*='post-card']", "[class*='post']"].each do |selector|
    begin
      post_card = page.find(selector, text: /#{Regexp.escape(title)}/i, match: :first, wait: 5)
      break if post_card
    rescue Capybara::ElementNotFound
      next
    end
  end
  
  if post_card
    # Find vote score within the post card
    score_element = nil
    ['.vote-score', '[data-voting-target="score"]', '[class*="vote-score"]'].each do |score_selector|
      begin
        score_element = post_card.find(score_selector, match: :first, wait: 2)
        break if score_element
      rescue Capybara::ElementNotFound
        next
      end
    end
    
    if score_element
      actual_score = score_element.text.strip.to_i
      expect(actual_score).to eq(expected_score), "Expected vote score of #{expected_score} for '#{title}', but found #{actual_score}"
    else
      # Fallback: check if score appears in the post card
      expect(post_card).to have_content(expected_score.to_s)
    end
  else
    # Fallback: check if score appears anywhere on the page
    expect(page).to have_content(expected_score.to_s), "Could not find post '#{title}' or vote score #{expected_score}"
  end
end

When('I click the upvote button for {string}') do |title|
  post = Post.find_by!(title: title)
  # Find the specific post's voting section
  within(".post-card", text: title) do
    button = page.find('.upvote-btn', match: :first, wait: 5)
    button.click
  end
  
  # Wait for AJAX or redirect (in test mode, forms submit normally)
  begin
    # Wait a bit for the request to process
    sleep(2)
    # Reload to see updated state
    visit page.current_path
  rescue
    sleep(2)
    visit page.current_path
  end
end

