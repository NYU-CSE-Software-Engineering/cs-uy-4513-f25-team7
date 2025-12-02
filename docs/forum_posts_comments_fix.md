# Forum Posts and Comments Feature - Fix Documentation

## Summary

Fixed the failing cucumber tests for the forum posts and comments feature (`features/forum_posts_and_comments.feature`). All 5 scenarios now pass with 42 steps.

## Originally Reported Failing Scenarios

```
cucumber features/forum_posts_and_comments.feature:11 # Scenario: Create a standard post successfully
cucumber features/forum_posts_and_comments.feature:23 # Scenario: Create a meta post successfully
cucumber features/forum_posts_and_comments.feature:34 # Scenario: Comment on a post
cucumber features/forum_posts_and_comments.feature:43 # Scenario: Fail to create a post without a title
cucumber features/forum_posts_and_comments.feature:50 # Scenario: I cannot comment
```

## Root Cause

The forum feature tests were correctly implemented, but a **syntax error in `team_editor_steps.rb`** prevented ALL cucumber step definitions from loading.

### The Bug (in `team_editor_steps.rb` lines 39-49)

The step definition had:
1. An unclosed table string (missing `})`)
2. A missing `end` statement for the `each` block

**Before (broken):**
```ruby
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
```

**After (fixed):**
```ruby
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

## Changes Made

### File: `features/step_definitions/team_editor_steps.rb`

**Lines 39-51:** Fixed syntax error by:
- Added missing `})` to close the table string (after line 47)
- Added missing `end` to close the `each` block (after the table closing)

## Investigation Notes

### "3 Identical I should see Step Definitions" - NOT FOUND

The originally reported issue about ambiguous step definitions was investigated. Only **ONE** generic `Then('I should see {string}')` step exists in `common_steps.rb`. Other similar-looking steps have different patterns and do not cause ambiguity:

| File | Step Definition |
|------|-----------------|
| `common_steps.rb` | `Then('I should see {string}')` ← Generic |
| `identity_steps.rb` | `Then("I should see a message {string}")` |
| `identity_steps.rb` | `Then("I should see an error {string}")` |
| `moderation_steps.rb` | `Then("I should see a success banner {string}")` |

These are distinct patterns that don't conflict.

## Test Results

```
5 scenarios (5 passed)
42 steps (42 passed)
```

### Passing Scenarios:
- ✅ Create a standard post successfully
- ✅ Create a meta post successfully
- ✅ Comment on a post
- ✅ Fail to create a post without a title
- ✅ I cannot comment
