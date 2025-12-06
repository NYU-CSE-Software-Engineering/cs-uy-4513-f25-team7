# double definition error coming from socialgraph steps
# Given("I am a registered user") do
#   @user ||= User.create!(email: "test@example.com", password: "password123")
# end

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

When('I press "Create Post"') do
  click_button "Create Post"
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
    post_type: "Thread" # keep main branch's value here
  )
end

When('I view the post {string}') do |title|
  post = Post.find_by!(title: title)
  visit post_path(post)
end

When('I fill in "Add a comment" with {string}') do |comment_body|
  fill_in "Add a comment", with: comment_body
end

When('I press "Post Comment"') do
  click_button "Post Comment"
end

Given("I sign out") do
  click_link "Sign out" rescue nil
  visit destroy_user_session_path(method: :delete) rescue nil
end

Then("I should not see the comment form") do
  expect(page).not_to have_selector("form#new_comment")
end
