# Forum: Posts, Meta Posts, & Comments

## User Story

**As a** signed-in member  
**I want to** create posts (including meta posts) and comment on other users' posts  
**So that I** can share strategies, discuss the competitive meta, and engage with the Pokémon community

## Acceptance Criteria

1. **Standard Post Creation (Happy Path)**
   - A signed-in member can navigate to the new post page
   - The member can create a post by providing a title, selecting "Thread" as the post type, and adding body content
   - Upon successful creation, the member is redirected to the post's show page with a success message
   - The post displays the title and body content correctly

2. **Meta Post Creation (Happy Path)**
   - A signed-in member can create a meta post by selecting "Meta" as the post type
   - Meta posts are visually distinguished with a meta badge on the post show page
   - Meta posts follow the same creation flow as standard posts but are categorized differently

3. **Commenting on Posts (Happy Path)**
   - A signed-in member can view an existing post and see a comment form
   - The member can add a comment by filling in the comment field and submitting
   - Upon successful comment submission, the comment appears on the post page with a confirmation message
   - Comments are associated with the post and display the comment content

4. **Post Validation (Sad Path)**
   - When a member attempts to create a post without a title, the system displays an error message "Title can't be blank"
   - The post is not created and the member remains on the new post form

5. **Guest Comment Restriction (Sad Path)**
   - When a guest (not signed in) views a post, they cannot see the comment form
   - Instead, guests see a message prompting them to sign in to comment
   - This enforces the role-based permissions outlined in the project specification

## MVC Components

### Models

**Post Model**
- Attributes:
  - `title:string` (required) - The title of the post
  - `body:text` (required) - The main content of the post
  - `post_type:string` - Type of post (e.g., "Thread", "Meta", "Strategy", "Announcement")
  - `user_id:integer` (foreign key) - References the user who created the post
  - `created_at:datetime` - Timestamp of post creation
  - `updated_at:datetime` - Timestamp of last update
- Associations:
  - `belongs_to :user` - A post belongs to a user
  - `has_many :comments, dependent: :destroy` - A post can have multiple comments
- Validations:
  - Validates presence of `title`
  - Validates presence of `body`
  - Validates presence of `post_type`
  - Validates `post_type` is included in allowed types (Thread, Meta, Strategy, Announcement, etc.)

**Comment Model**
- Attributes:
  - `body:text` (required) - The content of the comment
  - `post_id:integer` (foreign key) - References the post being commented on
  - `user_id:integer` (foreign key) - References the user who created the comment
  - `created_at:datetime` - Timestamp of comment creation
  - `updated_at:datetime` - Timestamp of last update
- Associations:
  - `belongs_to :post` - A comment belongs to a post
  - `belongs_to :user` - A comment belongs to a user
- Validations:
  - Validates presence of `body`

**User Model** (existing, relevant attributes)
- Attributes:
  - `email:string` - User's email for authentication
  - `encrypted_password:string` - Encrypted password
  - `role:string` - User role (guest, member, moderator, admin)
- Associations:
  - `has_many :posts, dependent: :destroy` - A user can create multiple posts
  - `has_many :comments, dependent: :destroy` - A user can create multiple comments

### Views

**posts/new.html.erb**
- Form for creating a new post
- Fields:
  - Title input field
  - Post Type dropdown (Thread, Meta, Strategy, Announcement)
  - Body textarea
  - Submit button ("Create Post")
- Displays validation errors if present
- Only accessible to signed-in members

**posts/show.html.erb**
- Displays a single post with:
  - Post title
  - Post type badge (especially highlighting "Meta" posts with `[data-test-id='post-badge-meta']`)
  - Post body content
  - Author information
  - Creation timestamp
- Comment section:
  - List of existing comments with author and timestamp
  - Comment form (if user is signed in) with textarea labeled "Add a comment" and submit button "Post Comment"
  - Sign-in prompt message for guests: "Please sign in to comment."
- Container marked with `[data-test-id='post-show']` for testing

**posts/index.html.erb** (anticipated)
- List of all posts
- Each post shows title, excerpt, author, and post type
- Links to individual post show pages
- Filter/search functionality (future enhancement)

**comments/_form.html.erb** (partial)
- Reusable comment form component
- Textarea field labeled "Add a comment"
- Submit button labeled "Post Comment"
- Only rendered for authenticated members

### Controllers

**PostsController**
- Actions:
  - `index` - Lists all posts (GET /posts)
  - `show` - Displays a single post with comments (GET /posts/:id)
  - `new` - Displays the new post form (GET /posts/new)
    - Requires user to be signed in
  - `create` - Creates a new post (POST /posts)
    - Requires user to be signed in
    - Sets current_user as the post author
    - On success: redirects to post show page with success flash message
    - On failure: re-renders new form with error messages
  - `edit` - Displays edit form (GET /posts/:id/edit) - future enhancement
  - `update` - Updates a post (PATCH /posts/:id) - future enhancement
  - `destroy` - Deletes a post (DELETE /posts/:id) - moderator/admin only
- Before Actions:
  - `authenticate_user!` for new, create, edit, update, destroy
  - `set_post` for show, edit, update, destroy
- Strong Parameters:
  - Permits: `title`, `body`, `post_type`

**CommentsController**
- Actions:
  - `create` - Creates a new comment on a post (POST /posts/:post_id/comments)
    - Requires user to be signed in
    - Associates comment with the current_user and the specified post
    - On success: redirects back to post show page with success flash message
    - On failure: redirects back with error message
  - `destroy` - Deletes a comment (DELETE /comments/:id) - author/moderator/admin only
- Before Actions:
  - `authenticate_user!` for all actions
  - `set_post` for create
  - `set_comment` and `authorize_user` for destroy
- Strong Parameters:
  - Permits: `body`

**ApplicationController** (inherited features)
- Devise authentication helpers (`authenticate_user!`, `current_user`, `user_signed_in?`)
- Role-based authorization helpers (to be implemented for moderator/admin actions)

## Routes

```ruby
resources :posts do
  resources :comments, only: [:create]
end
resources :comments, only: [:destroy]
```

This generates routes like:
- `GET /posts` - posts#index
- `GET /posts/new` - posts#new
- `POST /posts` - posts#create
- `GET /posts/:id` - posts#show
- `POST /posts/:post_id/comments` - comments#create
- `DELETE /comments/:id` - comments#destroy

## Additional Notes

### Authentication & Authorization
- Uses Devise for authentication
- Only signed-in members can create posts and comments
- Guests can view posts but cannot interact
- Future: Moderators can lock/pin posts, delete comments

### Post Types
The system supports multiple post types as defined in the project specification:
- **Thread**: Standard discussion posts
- **Meta**: Meta-game strategy posts (highlighted with special badge)
- **Strategy**: In-depth strategy guides
- **Announcement**: Important community announcements (moderator/admin only)
- **Review**: Team reviews (handled in a separate feature)

### Future Enhancements
- Rich text editing for post body
- Tagging system for posts
- Search and filtering
- Post voting/rating (karma system)
- Nested comments (replies)
- Post pinning and locking (moderator feature)
- Real-time notifications when someone comments on your post
