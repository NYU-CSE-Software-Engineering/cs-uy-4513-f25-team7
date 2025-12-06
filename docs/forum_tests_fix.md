# Forum Posts and Comments Feature Tests Fix

## Summary

This document describes the fixes applied to make the `forum_posts_and_comments.feature` cucumber tests pass in CI.

## Issues Identified

### 1. Syntax Error in `team_editor_steps.rb`

**File:** `features/step_definitions/team_editor_steps.rb`

**Problem:** The step definition file had a broken step definition around lines 39-49. The `When(/^I add Pokémon slots (\d+) through (\d+) with valid configurations$/)` step had:
- An unclosed table string (missing `})`)
- Missing `end` statement for the `each` block

This syntax error prevented cucumber from loading any step definition files, causing all tests to fail with a syntax error.

**Fix:** Properly closed the table string and added the missing `end` statement for the `each` loop:

```ruby
# Before (broken):
When(/^I add Pokémon slots (\d+) through (\d+) with valid configurations$/) do |start_idx, end_idx|
  (start_idx.to_i..end_idx.to_i).each do |i|
    step %{I add Pokémon slot #{i} with:}, table(%{
      | Species   | Pikachu       |
      | Item      | Focus Sash    |
      | Ability   | Static        |
      | Nature    | Timid         |
      | EVs       | 0 HP / 0 Atk / 0 Def / 252 SpA / 4 SpD / 252 Spe |
      | IVs       | 31 / 0 / 31 / 31 / 31 / 31 |
  expect(page).to have_content("Last saved").or have_css("[data-last-saved]")
end

# After (fixed):
When(/^I add Pokémon slots (\d+) through (\d+) with valid configurations$/) do |start_idx, end_idx|
  (start_idx.to_i..end_idx.to_i).each do |i|
    step %{I add Pokémon slot #{i} with:}, table(%{
      | Species   | Pikachu       |
      | Item      | Focus Sash    |
      | Ability   | Static        |
      | Nature    | Timid         |
      | EVs       | 0 HP / 0 Atk / 0 Def / 252 SpA / 4 SpD / 252 Spe |
      | IVs       | 31 / 0 / 31 / 31 / 31 / 31 |
    })
  end
  expect(page).to have_content("Last saved").or have_css("[data-last-saved]")
end
```

### 2. Sign Out Step Not Working Properly

**File:** `features/step_definitions/social_graph_notifications_steps.rb`

**Problem:** The "I sign out" step was trying to click a link with text "Sign out" using `click_link "Sign out"`, but the application layout (`app/views/layouts/application.html.erb`) uses a button with text "Log out" (`button_to "Log out"`).

Additionally, after fixing to use the correct text, Capybara found 2 buttons matching "Log out" on the page, causing an ambiguous match error.

**Fix:** Updated the sign out step to:
1. Look for both button and link variants with different text options
2. Use `first(:button, ...)` to handle multiple matching elements
3. Add verification that the user is actually signed out

```ruby
# Before (broken):
Given('I sign out') do
  click_link "Sign out" rescue nil
end

# After (fixed):
Given('I sign out') do
  if page.has_button?("Log out")
    first(:button, "Log out").click
  elsif page.has_link?("Log out")
    first(:link, "Log out").click
  elsif page.has_link?("Sign out")
    first(:link, "Sign out").click
  end
  # Wait for signed out state - should see Login link
  expect(page).to have_link("Login").or have_link("Log in").or have_link("Sign in")
end
```

## Files Changed

| File | Change |
|------|--------|
| `features/step_definitions/team_editor_steps.rb` | Fixed syntax error - properly closed table string and added missing `end` statement |
| `features/step_definitions/social_graph_notifications_steps.rb` | Updated sign out step to handle `button_to` with "Log out" text and disambiguate multiple matching elements |

## Test Results

All 5 scenarios in `forum_posts_and_comments.feature` now pass:

- ✅ Create a standard post successfully
- ✅ Create a meta post successfully
- ✅ Comment on a post
- ✅ Fail to create a post without a title
- ✅ I cannot comment

## Impact on Other Features

The changes made do not negatively impact other feature tests:
- The syntax fix in `team_editor_steps.rb` was a bug that affected all cucumber tests
- The sign out step change is more robust and handles the actual application UI correctly

## Notes for Team Members

1. When adding `button_to` elements in views, remember that cucumber/Capybara will look for them as buttons, not links
2. Use `first(:button, ...)` or `first(:link, ...)` when there might be multiple matching elements on a page
3. Always verify state changes (like sign out) to ensure the action actually succeeded

