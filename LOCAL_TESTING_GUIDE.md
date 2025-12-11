# Local Testing Guide

## Quick Start Testing

### 1. Install Dependencies
```bash
# If you haven't already, install gems
bundle install
```

**Note:** If you encounter Windows-specific gem compilation errors (like `psych` or `oauth2`), you may need to:
- Use WSL (Windows Subsystem for Linux)
- Or test in a Linux/macOS environment
- Or install MSYS2 development tools for Windows

### 2. Setup Database
```bash
# Reset and migrate the database
rails db:reset
# OR if that fails:
rails db:drop db:create db:migrate
```

### 3. Start the Rails Server
```bash
rails server
# or
rails s
```

The server will start at `http://localhost:3000`

### 4. Manual Testing Checklist

#### A. Forum Posts (Basic Functionality)
1. **Navigate to Forum**
   - Go to `http://localhost:3000/posts`
   - Should see the forum page with search/filter UI

2. **Create a Post**
   - Click "New Post"
   - Fill in:
     - Title: "Test Post"
     - Post Type: Select "Thread"
     - Body: "This is a test post body"
     - Tags: "test, example" (optional)
   - Click "Create Post"
   - Should redirect to post show page
   - Should see success message

3. **View Post**
   - Should see post title, body, and tags (if added)
   - Should see voting buttons (▲ and ▼) if votes table exists
   - Should see vote score (starts at 0)
   - Should see "Edit" and "Delete" buttons if you're the author

4. **Edit Post**
   - Click "Edit"
   - Modify title or body
   - Add/change tags
   - Click "Update Post"
   - Should see updated content

#### B. Voting System
1. **Upvote a Post**
   - Click the ▲ button on a post
   - Vote score should increase
   - Should see flash message "Upvoted!"

2. **Downvote a Post**
   - Click the ▼ button
   - Vote score should decrease
   - Should see flash message "Downvoted!"

3. **Vote Again**
   - Clicking the same vote button again should remove the vote
   - Clicking the opposite button should change the vote

#### C. Tagging System
1. **Create Post with Tags**
   - Create a post with tags: "ruby, rails, testing"
   - Tags should appear as clickable links on the post

2. **Filter by Tag**
   - Click on a tag link
   - Should see only posts with that tag
   - URL should include `?tag=ruby`

3. **Popular Tags**
   - On the forum index, should see "Popular Tags" section
   - Shows tags with post counts: "(5 posts)"

4. **Search and Filter**
   - Use the search box to search for text
   - Use the tag dropdown to filter by tag
   - Can combine search + tag filter

#### D. Pagination
1. **Create Multiple Posts**
   - Create at least 11 posts (more than 10 per page)
   - Should see pagination controls at bottom

2. **Navigate Pages**
   - Click page numbers or "Next"/"Previous"
   - Should see different posts on each page
   - URL should include `?page=2`

#### E. Comments
1. **Add Comment**
   - View a post
   - Scroll to comments section
   - Fill in "Add a comment" field
   - Click "Post Comment"
   - Should see your comment appear

2. **Delete Comment**
   - As the comment author, should see "Delete Comment" button
   - Click to delete
   - Comment should disappear

### 5. Run Cucumber Tests

```bash
# Run all tests
bundle exec cucumber

# Run specific feature
bundle exec cucumber features/forum_posts_and_comments.feature
bundle exec cucumber features/voting_system.feature
bundle exec cucumber features/advanced_tagging.feature
bundle exec cucumber features/pagination.feature

# Run with progress output
bundle exec cucumber --format progress
```

### 6. Check for Errors

#### Browser Console
1. Open browser developer tools (F12)
2. Check Console tab for JavaScript errors
3. Should see no errors related to:
   - `voting_controller.js`
   - Stimulus controllers
   - Form submissions

#### Rails Logs
1. Check the terminal where `rails server` is running
2. Look for:
   - SQL errors
   - Missing table errors
   - Route errors

#### Common Issues to Check

1. **Voting Not Working**
   - Check if `votes` table exists: `rails db:migrate:status`
   - Check browser console for JavaScript errors
   - Verify routes: `rails routes | grep vote`

2. **Tags Not Showing**
   - Check if `tags` and `post_tags` tables exist
   - Verify tags are being saved: Check database or Rails console

3. **Pagination Not Working**
   - Check if Kaminari is installed: `bundle list | grep kaminari`
   - Verify `@posts` responds to `.page`: Check in Rails console

4. **Styling Issues**
   - Hard refresh browser (Ctrl+F5 or Cmd+Shift+R)
   - Check if CSS is loading: View page source and check stylesheet link
   - Verify `application.css` is being served

### 7. Rails Console Testing

```bash
rails console
```

Test in console:
```ruby
# Check if tables exist
ActiveRecord::Base.connection.table_exists?('votes')
ActiveRecord::Base.connection.table_exists?('tags')
ActiveRecord::Base.connection.table_exists?('post_tags')

# Check posts
Post.count
Post.first.tags
Post.first.vote_score

# Check tags
Tag.count
Tag.popular(10)

# Test pagination
Post.page(1).per(10)
```

### 8. Database Verification

```bash
# Check migration status
rails db:migrate:status

# Should see these migrations (if they exist):
# - create_tags_post_tags_votes
# - Any other tag/vote related migrations
```

### 9. Quick Smoke Test Script

Create a simple test:
1. Start server: `rails s`
2. Open browser: `http://localhost:3000/posts`
3. Create a post with tags
4. Vote on the post
5. Add a comment
6. Filter by tag
7. Check pagination (if >10 posts)

If all of these work, your frontend is working correctly!

## Troubleshooting

### If bundle install fails:
- Try: `bundle update`
- Or: Install missing system dependencies
- Or: Use WSL/Linux environment

### If migrations fail:
- Check: `rails db:migrate:status`
- Reset: `rails db:reset` (WARNING: deletes all data)
- Or: `rails db:rollback` then `rails db:migrate`

### If server won't start:
- Check: `rails db:create` if database doesn't exist
- Check: Port 3000 is not in use
- Check: Ruby version matches `.ruby-version`

### If tests fail:
- Check: Database is set up correctly
- Check: All migrations are run
- Check: Test database: `RAILS_ENV=test rails db:migrate`

## Success Criteria

✅ Forum page loads without errors
✅ Can create posts with tags
✅ Voting buttons appear and work
✅ Tags are clickable and filter posts
✅ Pagination appears when >10 posts
✅ Comments can be added
✅ All styling matches dark theme
✅ No JavaScript console errors
✅ All Cucumber tests pass

