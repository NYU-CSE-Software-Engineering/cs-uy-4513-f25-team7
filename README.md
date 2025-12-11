# PokéForum 🎮🧬

PokéForum is a Pokémon-themed community forum where trainers can share strategies, discuss their favorite species, build competitive teams, and keep up with friends via a personalized **My Feed**. It is a Ruby on Rails web application built as a course project and includes social, moderation, and security features such as following trainers and species, role-based permissions, team reviews, and two-factor authentication.

We are online 🚀  https://pokeforum-9a8c59f0af40.herokuapp.com/

---

## Table of Contents 📚

1. [Features](#features)  
2. [Core Domain Concepts](#core-domain-concepts)  
3. [Navigation Overview](#navigation-overview)  
4. [My Feed](#my-feed)  
5. [Following Trainers, Teams, and Species](#following-trainers-teams-and-species)  
6. [Architecture Notes](#architecture-notes)  
7. [Getting Started](#getting-started)  
8. [Running the App](#running-the-app)  
9. [Testing](#testing)  
10. [Future Improvements](#future-improvements)

---

## Features ✨

### Authentication, Sessions & Security 🔐

- Users can register, log in, and log out.
- `ApplicationController` exposes `current_user` and `user_signed_in?` helpers for views and controllers.
- Access control helpers:
  - `require_login` – generic login gate.
  - `authenticate_user!` – Devise-style shim that delegates to `require_login`.
  - `require_moderator`, `require_admin`, `require_moderator_or_admin` – role-based guards for restricted features.
- `SessionsController` implements:
  - Email/password login using `has_secure_password`.
  - Account lockout via `Identity::LockoutTracker` after a configurable number of failed attempts (default 5 attempts, 15-minute lockout).
  - Google OAuth login (create or link a `User` via Google profile, with token persistence).
- `TwoFactorController` implements TOTP-based two-factor authentication (2FA):
  - Users can enroll in 2FA (QR code provisioning using `ROTP` and `rqrcode`).
  - A dedicated 2FA login prompt is shown when OTP is enabled.
  - Login flow supports a “pending user” state until OTP is verified.

### Accounts & Role Management 👤👑

- **Profile / Accounts**
  - `AccountsController#edit` / `#update` allow users to update their profile (currently username) and see 2FA / OAuth options.
- **Bootstrap Admin Flow**
  - `AccountsController#admin_setup` / `#become_admin` implement a “first admin” bootstrap:
    - Admin setup is allowed only when there are no existing admins.
    - A secret code (`ADMIN_SECRET_CODE`, default `"pokeforum2024"`) promotes the current user to admin.
- **Role Management**
  - Three primary roles: `user`, `moderator`, and `admin`.
  - Admin-only **Role Management** page (`UsersController#index`) lists users and allows role updates.
  - `UsersController#update` sets flash messages tailored for Cucumber scenarios (e.g., "Role updated successfully", "`email` is now a moderator").

### Forum Posts & Comments 💬

- **Forum Posts**
  - General forum posts are handled by `PostsController`.
  - Posts belong to a `User` and support four high-level categories via `post_type`:
    - `Announcement` 📢
    - `Strategy` ⚔️
    - `Meta` 📊
    - `Thread` 💭
  - The forum index groups posts by `post_type` and displays a styled list for each category with icons and descriptions.
  - Individual post pages show the full body, comments, and (for authorized users) a delete button.
- **Comments**
  - `CommentsController` allows authenticated users to comment on posts.
  - Comments belong to both a `Post` and a `User`.
  - Only the comment author, a moderator, or an admin can delete a comment.
  - User-friendly flash messages are shown when comment creation fails.

### Species Discussions 🧪🐉

- Species lookups are handled by `SpeciesController`.
- Uses a `DexSpecies` model plus a `Dex::PokeapiImporter` to lazily import species details when needed.
- Each species page (`/species/:name`) shows:
  - Basic sprite and name (from PokeAPI sprites repo, no extra API call).
  - Follow/unfollow state and follower count (via `FollowsController`).
  - A list of discussion posts for that species (`Post.for_species(dex_species_id)`).
  - A form for signed-in users to create a new species-specific post.

### Teams, Favorites & Reviews 🧩⭐

- **Team Builder**
  - `TeamsController` provides a rich team-builder flow:
    - Teams default to `private_team` + `draft` status on new.
    - Always enforces up to six `team_slots` per team, auto-building empty slots as needed.
    - Multiple actions through the same form:
      - **Validate** – run legality checks without saving.
      - **Save** – save a draft, mark legality, keep visibility as private.
      - **Publish** – re-run legality checks and publish as a public, visible team when legal.
      - **Add Pokémon** – add another team slot up to six.
  - Legality and visibility fields (e.g., `status`, `visibility`, `legal`, `last_saved_at`) are updated consistently.
- **Favorites**
  - `FavoritesController` lets users favorite certain resources (currently teams via polymorphic `favoritable`).
  - Prevents duplicate favorites and offers an "Already favorited" message when applicable.
  - On create, attempts to notify the owner of the favorited resource via a `Notification` (`event_type: "favorite_created"`).
- **Reviews**
  - `ReviewsController` enables rating and reviewing teams:
    - Reviews belong to a `Team` and a `User`.
    - The team owner receives a `Notification` when a new review is created.
    - Review authors can edit or delete their own reviews.
    - Moderators/admins can soft-delete any review and notify the reviewer (`event_type: "review_removed").

### Messaging & Notifications ✉️🔔

- **Direct Messages**
  - `MessagesController` implements private, inbox-style messaging:
    - Users can send messages to other users by `recipient_id` or `recipient_email`.
    - Only the message sender or recipient can view a given message.
    - Inbox (`index`) loads all received messages, ordered by `created_at DESC`.
    - When a recipient views a message, it is marked as read.
- **Notifications**
  - `NotificationsController#index` shows a chronological list of notifications for the current user.
  - Unread notifications are counted and then bulk-marked as read (`read_at` timestamp).
  - Notification types include:
    - `follow_created` when another user follows you.
    - `favorite_created` when your team is favorited.
    - `new_review` when your team receives a review.
    - `review_removed` when a moderator removes your review.

### Following Trainers & Species 🤝🐾

- **Following Trainers**
  - `UserFollowsController` manages follow relationships between users.
  - Users can follow other trainers (but not themselves) and unfollow them later.
  - A `Notification` with `event_type: "follow_created"` is created on follow.
- **Following Species**
  - `FollowsController` manages an in-memory follow state for species using class variables.
  - Helpers include:
    - `FollowsController.following_for(name)` – whether the current in-memory user follows a species.
    - `FollowsController.count_for(name)` – follower count for that species.
    - `FollowsController.followed_species` – list of all followed species names (used by the feed).
  - This in-memory approach keeps existing Cucumber scenarios working without persisting species follows to the database.

### My Feed 📰

- Personalized feed for each user at `/feed` (`FeedController#index`).
- Shows recent activity from:
  - Trainers the user follows.
  - Species the user follows.
  - Your own posts, **but only** when someone else has commented on them.
- Combines:
  - Posts authored by followed users.
  - Posts tagged with followed species (excluding your own when there is no external activity).
  - Your own posts that have comments from other users.
- Uses a custom `activity_timestamp` helper so posts are ordered by **most recent activity**:
  - For other users’ posts: the max of the post’s `created_at` and its latest comment.
  - For your own posts: only comments from *other users* affect the timestamp.
- Implements social rules so the feed feels relevant:
  - Your own un-commented posts never appear in your feed.
  - Your own comments on any post never create feed activity for yourself.
  - When a followed trainer comments on your post, the feed entry is based on the **most recent comment**, not the original post time.
- Still supports the existing `FakePostStore` used by feature tests; when this store is present, feed entries are derived from it instead of the database.

---

## Core Domain Concepts 🧱

- **User**
  - Has authentication fields, optional 2FA (`otp_secret`, `otp_enabled`), and optional Google OAuth linkage.
  - Has a `role` (`user`, `moderator`, `admin`).
  - Has follower/followee relationships via `UserFollowsController`.
  - Owns posts, teams, reviews, favorites, messages, and notifications.
- **Post**
  - Belongs to a `User` and optionally to a `DexSpecies` for species-specific discussions.
  - Has many `comments`.
  - Classified as general or species-specific; general posts appear on the Forum page, species posts on species pages.
  - In the feed, posts are ordered by most recent activity (post creation or latest external comment).
- **Comment**
  - Belongs to a `Post` and a `User`.
  - Drives activity in the feed and discussion on post pages.
- **Team**
  - Belongs to a `User`.
  - Has up to six `team_slots` capturing Pokémon, moves, EVs/IVs, etc.
  - Has legality state and visibility (`draft` vs `published`, `private_team` vs `public_team`).
- **Favorite**
  - Polymorphic favorite relationship (currently used for teams).
  - Triggers a notification to the resource owner.
- **Review**
  - Rating + body text attached to a team and a user.
  - Supports soft deletion for moderation and triggers notifications.
- **Message**
  - Direct message between two users (sender and recipient).
  - Tracks read/unread state.
- **Notification**
  - Belongs to a user and references a “notifiable” resource (follow, favorite, review, team, etc.).
  - Used to surface social activity in the Notifications page.
- **DexSpecies**
  - Represents a Pokémon species imported from PokeAPI.
  - Linked to posts via `dex_species_id`.
- **Species Follow State**
  - Maintained in memory via `FollowsController` class variables.
  - Exposes follower counts and “following” state for species pages and the feed.

---

## Navigation Overview 🧭

The main navigation (in `app/views/layouts/application.html.erb`) includes:

- **Home** – Dashboard / welcome page.
- **Forum** – General forum posts (`PostsController#index`).
- **Species** – Species search & show (`SpeciesController#index` / `show`).
- **My Teams** – Team builder and published teams (`TeamsController`).
- **My Feed** – Personalized activity feed (`FeedController#index`).
- **Messages** (if linked in the layout) – Direct messages inbox (`MessagesController#index`).
- **Favorites** (optional link) – List of your favorited resources (`FavoritesController#index`).
- **Notifications** – Notification center for social activity (`NotificationsController#index`).
- **👑 Admin** – Role Management and other admin features (visible only to admins).
- **Settings** – Account settings (profile / 2FA / OAuth).
- **Log out** – Ends the user’s session.

The header is shared via the `application` layout and uses a dark theme with `Plus Jakarta Sans`.

---

## My Feed 🔄

The **My Feed** feature is implemented primarily in:

- `app/controllers/feed_controller.rb`
- `app/views/feed/index.html.erb`

### Controller Responsibilities

1. **Determine Followed Species**
   - Reads the list of followed species names from `FollowsController.followed_species`.

2. **Test vs Real Data**
   - First checks `FakePostStore.all`. When present (in tests), the feed is built purely from this in-memory store.
   - When `FakePostStore` is empty, the controller falls back to real `Post` and `Comment` records.

3. **Build Feed Sources**
   - Build `friend_ids` from `current_user.followees`.
   - Query three sets of post IDs from a common `base_scope` (`Post.includes(:user, :comments, :dex_species)`):
     - Posts authored by followed users.
     - Posts tagged with followed species (excluding your own to avoid self-spam).
     - Your own posts that have at least one comment written by someone else.
   - Union and de-duplicate IDs, then load the posts.

4. **Order by Activity**
   - Sorts posts in Ruby by `activity_timestamp(post, current_user)`:
     - For your own posts, only other users’ comments count as “activity”.
     - For others’ posts, both the post time and comment times are considered.

### View Responsibilities

- Converts each post into an activity card with:
  - `title`, `author`, `timestamp`, `body`, `comments_n`.
  - `species_name` (if the post is attached to a `DexSpecies`).
- For posts authored by the current user:
  - Looks for comments from *other* users.
  - If any exist, the metadata line becomes:

    ```text
    <other_user> commented · <when> ago
    ```

    and the body preview shows the latest comment.
  - If no other comments exist, the post is effectively invisible in the feed.
- For regular posts, the metadata line looks like:

  ```text
  Posted by <author> · <time> ago · in <Species>
  ```

  where `in <Species>` is shown only for species posts and links to the species show page.
- Empty states:
  - If there are feed items, a “no more posts to show” card appears after the last one.
  - If there are no feed items at all, a “Your feed is empty” card encourages following trainers or starting discussions.

---

## Following Trainers, Teams, and Species 🌐

### Trainers (`UserFollowsController`)

- Ensures the current user is logged in (`ensure_social_login`).
- Keeps users from following themselves.
- Prevents duplicate follow relationships.
- On follow:
  - Creates a `Notification` and shows “Following”.
- On unfollow:
  - Destroys the relationship and shows “Unfollowed `display_name`”.

### Teams (`FavoritesController` & `ReviewsController`)

- Users can:
  - Favorite teams for quick access and to support their creators. ⭐
  - Review teams with a rating and feedback. 📝
- Team owners receive notifications for:
  - New favorites.
  - New reviews.
  - Review removals by moderators.

### Species (`FollowsController`)

- Uses an in-memory map for followed/unfollowed species, mirroring the original Cucumber design.
- `create` / `destroy` toggle follow state and adjust counts, then redirect to the species page.
- Helper methods are used by both species pages and the feed.

---

## Architecture Notes 🏗️

- **Layout**
  - Global layout in `app/views/layouts/application.html.erb`.
  - Uses a shared header, flash messages, and a container for page content.
  - Includes a small inline script for card hover effects and a `turbo:load` hook.

- **Controller Overview**
  - `ApplicationController` – authentication helpers and role guards.
  - `SessionsController` – password login, lockout, Google OAuth.
  - `TwoFactorController` – 2FA enrollment and verification.
  - `AccountsController` – profile editing and admin bootstrap.
  - `UsersController` – user profiles and admin role management.
  - `UserFollowsController` – trainer follow/unfollow.
  - `FollowsController` – species follow/unfollow (in-memory).
  - `PostsController` / `CommentsController` – forum posts and comments.
  - `SpeciesController` – species lookup and species-specific posts.
  - `TeamsController` – team builder and publish flow.
  - `FavoritesController` – favorites for teams.
  - `ReviewsController` – team reviews with moderation.
  - `MessagesController` – direct messages.
  - `NotificationsController` – notification index.
  - `FeedController` – personalized activity feed.

---

## Getting Started 🚀

> These steps assume you already have Ruby, Bundler, and a supported database (e.g., PostgreSQL or SQLite) installed.

1. **Clone the repository**

   ```bash
   git clone <your-repo-url>.git
   cd <your-repo-folder>
   ```

2. **Install dependencies**

   ```bash
   bundle install
   ```

3. **Set up the database**

   ```bash
   bin/rails db:setup
   ```

   or, if you prefer the explicit sequence:

   ```bash
   bin/rails db:create
   bin/rails db:migrate
   bin/rails db:seed   # if seeds are available
   ```

4. **Configure environment variables**

   At minimum:

   - `ADMIN_SECRET_CODE` – secret code used to bootstrap the first admin account (defaults to `"pokeforum2024"` if unset).

   Optional but recommended:

   - Google OAuth credentials (`GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET`, callback URL) if you want to use Google sign-in.
   - Any additional secrets your course or deployment environment requires.

---

## Running the App 🏃‍♂️

Start the Rails server:

```bash
bin/rails server
```

Then visit:

- `http://127.0.0.1:3000/` – Home/dashboard.  
- `http://127.0.0.1:3000/posts` – Forum index.  
- `http://127.0.0.1:3000/species` – Species search page.  
- `http://127.0.0.1:3000/feed` – My Feed (requires login).  
- `http://127.0.0.1:3000/messages` – Direct messages inbox.  
- `http://127.0.0.1:3000/favorites` – Favorites page (if route is enabled).  
- `http://127.0.0.1:3000/notifications` – Notifications center.

Create a test user account (or log in with seeded credentials) to explore My Feed, follows, messaging, teams, and admin features.

---

## Testing ✅

The project uses both automated tests and Cucumber feature tests (as indicated by `FakePostStore` and the in-memory `FollowsController`).

### Running Tests

Typical commands may look like:

```bash
bundle exec rspec     # model and controller specs (if configured)
bundle exec cucumber  # feature tests (if configured)
```

### Test Coverage

The project uses SimpleCov to track test coverage. Coverage is enabled by default when running tests.

#### Running Tests with Coverage

Coverage is automatically generated when you run tests:

```bash
bundle exec rspec     # generates coverage for RSpec tests
bundle exec cucumber  # generates coverage for Cucumber tests
```

Both test suites contribute to the same coverage report, which is merged automatically.

#### Viewing Coverage Reports

After running tests, open the coverage report in your browser:

```bash
open coverage/index.html    # macOS
xdg-open coverage/index.html  # Linux
start coverage/index.html   # Windows
```

The coverage report shows:
- Overall line and branch coverage percentages
- Coverage breakdown by file and directory
- Highlighted source code showing which lines are covered

#### Disabling Coverage for Faster Test Runs

If you need faster test runs during development, you can disable coverage:

```bash
COVERAGE=false bundle exec rspec
COVERAGE=false bundle exec cucumber
```

This skips coverage tracking and report generation, which can significantly speed up test execution.

#### Continuous Integration

Coverage reports are automatically generated and published on every push to `main` or `ci/**` branches. The published reports are available at: https://nyu-cse-software-engineering.github.io/cs-uy-4513-f25-team7/

---

## Future Improvements 🔮

Some ideas for future iterations of PokéForum:

- Persist species follows in the database instead of the in-memory `FollowsController`, while keeping compatibility shims for tests.
- Add pagination or infinite scrolling to the feed, forum index, and team lists.
- Add a richer notification center UI (filter by type, mark individual items as unread, etc.).
- Surface unread counts in the main navigation for messages and notifications.
- Support richer post formatting (markdown, spoilers, embeds, etc.).
- Add search across posts, comments, teams, and species.
- Add webhooks or background jobs for heavy tasks (e.g., sending email notifications).

---

Happy training and enjoy using **My Feed** to keep up with your favorite trainers, teams, and Pokémon species! 🎉🐾
