# Shared step definitions used across multiple features
# This prevents ambiguous step definition errors

Given('the forum is running') do
  # Rails app should be running - no action needed for Cucumber
  # This step is just a placeholder
end

Then('I should see {string}') do |text|
  expect(page).to have_content(text)
end

Then("I should not see {string}") do |text|
  expect(page).not_to have_content(text)
end

Given('I am a registered user') do
  @current_user ||= User.find_or_create_by!(email: "test@example.com") do |u|
    u.password = "password123"
    u.password_confirmation = "password123"
  end
  @user = @current_user
end

When("I press {string}") do |text|
  # Try button first (exact match)
  if page.has_button?(text, exact: true)
    click_button text, exact: true
  # Try button with partial match
  elsif page.has_button?(text)
    click_button text
  # Try link
  elsif page.has_link?(text)
    click_link text
  # Try to find submit button in a form (button_to creates forms with submit buttons)
  elsif page.has_css?("input[type='submit'][value='#{text}']")
    find("input[type='submit'][value='#{text}']").click
  # Try to find button with matching text (case insensitive)
  elsif page.has_css?("button", text: /#{Regexp.escape(text)}/i)
    find("button", text: /#{Regexp.escape(text)}/i).click
  # Try to find within button_to forms - button_to creates a form with a submit input
  elsif page.has_css?("form input[type='submit']", text: /#{Regexp.escape(text)}/i)
    find("form input[type='submit']", text: /#{Regexp.escape(text)}/i).click
  # Try finding by form action and button text
  elsif text.include?("Delete")
    # For delete buttons, try to find the form and its submit button
    form = page.find("form", text: /#{Regexp.escape(text)}/i, match: :first) rescue nil
    if form
      form.find("input[type='submit']").click
    else
      # Try finding any submit button with the text
      find("input[type='submit']", text: /#{Regexp.escape(text)}/i, match: :first).click
    end
  else
    # Last resort: try to find any element with the text
    find("*", text: text, match: :first).click
  end
end

# Removed duplicate - using social_graph_notifications_steps.rb version
# This prevents ambiguous match errors

