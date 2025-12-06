# Shared step definitions used across multiple features
# This prevents ambiguous step definition errors

Then('I should see {string}') do |text|
  expect(page).to have_content(text)
end

When('I press {string}') do |button|
  click_button button
end
