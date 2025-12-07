# Shared step definitions used across multiple features
# This prevents ambiguous step definition errors

Then('I should see {string}') do |text|
  expect(page).to have_content(text)
end

Then("I should not see {string}") do |text|
  expect(page).not_to have_content(text)
end


When("I press {string}") do |text|
  if page.has_button?(text)
    click_button text
  else
    click_link text
  end
end

