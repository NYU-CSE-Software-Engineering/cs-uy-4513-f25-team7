# Social Graph & Notifications (follow, favorite, inbox)

## Feature & User Story

**Feature:** Follow users, favorite content, and receive inbox notifications.

**User Story:**

As a signed-in member, I want to follow users and favorite teams/posts so that I get an inbox of notifications when people I follow post or when they interact with my content.

---

## Acceptance Criteria (happy + sad paths)

### AC1 — Follow a user

* **Given** I am logged in
* **And** I am on another user’s profile
* **When** I click **Follow**
* **Then** the button changes to **Following** (or  **Unfollow** )
* **And** that user’s follower count increases by 1
* **And** the followed user receives a **new notification** in their inbox.

**Sad path**

* If I click **Follow** again while already following, I see **“Already following”** and counts do not change.
* I cannot follow myself (no **Follow** button on my profile).

### AC2 — Favorite a team/post

* **Given** I am logged in and viewing a Team or Post
* **When** I click **Favorite**
* **Then** I see **Favorited** and the item appears in **My Favorites**
* **And** the item owner receives a **new notification** (unless I own the item).

**Sad path**

* Favoriting the same item twice is prevented and shows a friendly error.

### AC3 — Notifications inbox

* **Given** I am logged in
* **When** I visit **/notifications**
* **Then** I see newest notifications first with read/unread state and an unread count badge
* **And** opening the inbox marks unread notifications as read.

**Sad path**

* If I try to open **/notifications** while signed out, I am redirected to sign-in and see **“Please sign in to continue.”**

> The assignment expects 3–5 specific, testable criteria that cover happy and failure/edge cases.

---

## MVC Component Outline

*(Connects the BDD spec to Rails’ MVC.)*

### Models

* **Follow** (follower_id, followee_id)
* `belongs_to :follower, class_name: "User"`
* `belongs_to :followee, class_name: "User"`
* Validations: presence; uniqueness of `[follower_id, followee_id]`; cannot follow self.
* **Favorite** (user_id, favoritable_type, favoritable_id)
* `belongs_to :user`
* `belongs_to :favoritable, polymorphic: true` (Team or Post)
* Validations: presence; uniqueness of `[user_id, favoritable_type, favoritable_id]`.
* **Notification** (user_id, actor_id, event_type, notifiable_type, notifiable_id, read_at)
* `belongs_to :user` (recipient)
* `belongs_to :actor, class_name: "User"`
* `belongs_to :notifiable, polymorphic: true`
* Scopes: `.unread` → `where(read_at: nil)`.

### Controllers (server-rendered to start)

* **FollowsController** : `create` (follow), `destroy` (unfollow). Creates a notification to the followee on `create`.
* **FavoritesController** : `index` (My Favorites), `create`, `destroy`. Creates a notification to the owner on `create`.
* **NotificationsController** : `index` (list; mark all unread as read on load), optional `update` for mark-one-read.

### Views

* **User profile show:** Follow/Unfollow button, follower count.
* **Team/Post show:** Favorite/Unfavorite button; flash messages.
* **Notifications index:** list with type, actor, target, timestamp; unread badge.

### Routes (initial)

```ruby
resources :users, only: [:show] do
  resource :follow, only: [:create, :destroy]
end
resources :favorites, only: [:index, :create, :destroy]
resources :notifications, only: [:index, :update]
```

---

## BDD Specification (to mirror in `features/social_graph_notifications.feature`)

*(At least one happy and one failure/edge case scenario in Gherkin.)*

```gherkin
Feature: Follow, favorite, and inbox notifications
  As a signed-in member
  I want to follow users and favorite content
  So that I get notifications in my inbox

  Background:
    Given I am a signed-in user
    And there exists another user named "Misty"
    And there exists a public team called "Rain Dance" owned by "Misty"

  # --- Follow ---
  Scenario: Follow a user (happy path)
    When I visit Misty's profile
    And I click "Follow"
    Then I should see "Following"
    And I should see "1 follower" on Misty's profile
    And "Misty" should see a new notification in her inbox

  Scenario: Cannot follow twice (sad path)
    Given I already follow "Misty"
    When I click "Follow"
    Then I should see an error "Already following"

  Scenario: Cannot follow myself (sad path)
    When I visit my own profile
    Then I should not see "Follow"

  # --- Favorite ---
  Scenario: Favorite a team (happy path)
    When I visit the "Rain Dance" team page
    And I click "Favorite"
    Then I should see "Favorited"
    And I should find "Rain Dance" in My Favorites
    And "Misty" should see a new notification in her inbox

  Scenario: Must sign in to follow/favorite (sad path)
    Given I am signed out
    When I click "Follow" on Misty's profile
    Then I should be on the sign in page
    And I should see "Please sign in to continue"
```

---

## Step Definitions (Ruby/Capybara) – guidance

Run `bundle exec cucumber` to generate pending snippets, then implement them with Capybara actions in `features/step_definitions/social_steps.rb`.

**Common steps to implement**

* **Auth helper:** create a user, visit `new_user_session_path`, `fill_in` email/password, `click_button "Log in"`.
* **Data setup:** create `@other` user “Misty”; create `@team` owned by “Misty”.
* **UI actions:** `visit user_path(@other)`, `click_button "Follow"`, `click_button "Favorite"`.
* **Assertions:** `expect(page).to have_content("Following")`, check counts, visit `/notifications` and assert a new item exists.

---

## Non-functional notes

* Use flash messages for success/errors.
* Prevent double-submits (uniqueness validations).
* Only create notifications when actor ≠ recipient.
* Mark notifications read on inbox open (bulk update).

---

## Deliverables checklist (commit these paths)

* [ ] `docs/social_graph_&_notifications.md` (this file: story, criteria, MVC)
* [ ] `features/social_graph_notifications.feature` (Gherkin)
* [ ] `features/step_definitions/social_steps.rb` (Capybara steps)
* [ ] `features/screenshots/social_graph_notifications_1.jpg` (screenshot of failing Cucumber run)

**Team workflow:** create your own branch, open a PR, request a teammate to review, and merge after approval.

---

## Quick run notes (to get a “red” test run fast)

```bash
# Add gems in :test group, then:
bundle install
rails generate cucumber:install
bundle exec cucumber  # take a screenshot of the red output
```
