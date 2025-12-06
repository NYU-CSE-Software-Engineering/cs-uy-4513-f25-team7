# features/step_definitions/forum_steps.rb

When("I go to the new post page") do
  visit new_post_path
  expect(page).to have_selector("form#new_post")
end

When('I fill in "Title" with {string}') do |title|
  fill_in "Title", with: title
end

When('I fill in "Body" with {string}') do |body|
  fill_in "Body", with: body
end

When('I select {string} from "Post Type"') do |value|
  select value, from: "Post Type"
end

Then("I should be on the post show page") do
  expect(page).to have_css("[data-test-id='post-show']")
end

Then("I should see a meta badge") do
  expect(page).to have_css("[data-test-id='post-badge-meta']")
end

Given('a post titled {string} exists') do |title|
  @post = Post.create!(
    user: @user || User.create!(email: "author@example.com", password: "password123"),
    title: title,
    body: "Body for #{title}",
    post_type: "Thread"
  )
end

When('I view the post {string}') do |title|
  post = Post.find_by!(title: title)
  visit post_path(post)
end

When('I fill in "Add a comment" with {string}') do |comment_body|
  fill_in "Add a comment", with: comment_body
end

Then("I should not see the comment form") do
  expect(page).not_to have_selector("form#new_comment")
end

Given('a post titled {string} exists by {string}') do |title, email|
  user = User.find_or_create_by!(email: email) do |u|
    u.password = "password123"
    u.password_confirmation = "password123"
  end

  Post.find_or_create_by!(title: title, user: user) do |p|
    p.body = "Sample body for #{title}"
    p.post_type = "Thread"
  end
end

Given('the post {string} has a comment {string}') do |title, comment_body|
  post = Post.find_by!(title: title)
  commenter = User.find_or_create_by!(email: "commenter@example.com") do |u|
    u.password = "password123"
    u.password_confirmation = "password123"
  end
  post.comments.create!(body: comment_body, user: commenter)
end

When('I press "Delete Post"') do
  click_button "Delete Post"
end

When('I press "Delete Comment"') do
  click_button "Delete Comment"
end
