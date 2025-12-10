# Feature: Team Rating & Reviews

## Pull Request Summary

This PR implements a comprehensive **Team Rating & Reviews** system that allows users to rate and review published teams, helping the community discover high-quality competitive Pokémon builds.

---

## User Story

> *As a competitive Pokémon player browsing the forum, I want to rate and review published teams so that I can provide feedback to team builders and help others discover quality team compositions.*

---

## Acceptance Criteria

| AC | Description | Status |
|----|-------------|--------|
| AC1 | Submit a rating (1-5 stars) and optional review on published teams | ✅ |
| AC2 | View average rating, review count, and individual reviews on team pages | ✅ |
| AC3 | Edit or delete your own review | ✅ |
| AC4 | Browse teams by rating (scope for highest-rated teams) | ✅ |
| AC5 | Moderators can remove inappropriate reviews (soft-delete) | ✅ |

---

## Implementation Details

### Database Schema

**New Table: `reviews`**
| Column | Type | Description |
|--------|------|-------------|
| `id` | integer | Primary key |
| `team_id` | integer | FK → teams (indexed) |
| `user_id` | integer | FK → users (indexed) |
| `rating` | integer | 1-5 stars (required) |
| `body` | text | Review text (optional, max 500 chars) |
| `deleted_at` | datetime | Soft-delete timestamp for moderation |
| `created_at` | datetime | |
| `updated_at` | datetime | |

**Indexes:**
- `[team_id, user_id]` - Unique constraint (one review per user per team)
- `[team_id, deleted_at]` - For efficient visible review queries

**Modified Table: `teams`**
| Column | Type | Description |
|--------|------|-------------|
| `average_rating` | decimal(3,2) | Cached average rating (default: 0.0) |
| `reviews_count` | integer | Cached visible review count (default: 0) |

### Models

**`Review` Model**
- Validations: rating (1-5), body length (max 500), uniqueness per user/team
- Custom validation: users cannot review their own teams
- Scopes: `visible` (excludes soft-deleted), `by_recent`
- Callbacks: automatically updates team's cached rating on save/destroy
- Soft-delete support via `soft_delete!` method

**`Team` Model Updates**
- New association: `has_many :reviews`
- New method: `recalculate_rating!` - Updates cached rating from visible reviews
- New scope: `highest_rated(min_reviews:)` - For browsing top teams

### Controller

**`ReviewsController`** (nested under teams)
| Action | Route | Description |
|--------|-------|-------------|
| `create` | POST `/teams/:team_id/reviews` | Submit new review |
| `edit` | GET `/teams/:team_id/reviews/:id/edit` | Edit form |
| `update` | PATCH `/teams/:team_id/reviews/:id` | Update review |
| `destroy` | DELETE `/teams/:team_id/reviews/:id` | Delete (hard) or remove (soft for mods) |

### Views

- `teams/show.html.erb` - Updated with reviews section
- `reviews/_summary.html.erb` - Star rating display with count
- `reviews/_form.html.erb` - Star picker and text area
- `reviews/_review.html.erb` - Individual review card
- `reviews/edit.html.erb` - Edit review page

### Notifications

The system creates notifications for:
- `new_review` - When someone reviews your team
- `review_removed` - When a moderator removes your review

---

## Files Changed

### New Files
```
app/models/review.rb
app/controllers/reviews_controller.rb
app/views/reviews/_summary.html.erb
app/views/reviews/_form.html.erb
app/views/reviews/_review.html.erb
app/views/reviews/edit.html.erb
db/migrate/YYYYMMDD_create_reviews.rb
db/migrate/YYYYMMDD_add_rating_fields_to_teams.rb
spec/models/review_spec.rb
spec/requests/reviews_spec.rb
features/team_reviews.feature
features/step_definitions/team_reviews_steps.rb
test/fixtures/reviews.yml
```

### Modified Files
```
app/models/team.rb
app/views/teams/show.html.erb
config/routes.rb
```

---

## Testing

### RSpec Tests
- **Model specs** (`spec/models/review_spec.rb`): 15 examples covering validations, scopes, soft-delete, and rating calculations
- **Request specs** (`spec/requests/reviews_spec.rb`): 9 examples covering create, update, delete, authorization

### Cucumber Features
- **Feature file** (`features/team_reviews.feature`): 7 scenarios covering all acceptance criteria

### Running Tests
```bash
# Run all RSpec tests
bundle exec rspec

# Run review-specific tests
bundle exec rspec spec/models/review_spec.rb spec/requests/reviews_spec.rb

# Run Cucumber tests
bundle exec cucumber --format progress

# Run review-specific Cucumber scenarios
bundle exec cucumber features/team_reviews.feature
```

---

## Manual Testing Guide

1. **Create a published public team** (or use an existing one)
2. **Log in as a different user** and navigate to the team page
3. **Submit a review** with a star rating and optional text
4. **Verify** the rating summary updates
5. **Edit your review** and verify changes
6. **Delete your review** and verify removal
7. **Log in as a moderator** and verify you can remove other users' reviews
8. **Check notifications** for the team owner

---

## Screenshots

*Add screenshots here after manual testing*

---

## Breaking Changes

None. This is a new feature that doesn't modify existing functionality.

---

## Future Enhancements (Out of Scope)

- Helpful/unhelpful voting on reviews
- Review replies from team owner
- Weekly "Top Rated Teams" digest
- Badge system for prolific reviewers
- Sort teams index by rating

---

## Checklist

- [x] Database migrations created
- [x] Model with validations and associations
- [x] Controller with CRUD actions
- [x] Views for displaying and submitting reviews
- [x] Routes configured (nested under teams)
- [x] Notifications integration
- [x] RSpec tests passing
- [x] Cucumber tests passing
- [x] No regressions in existing tests

