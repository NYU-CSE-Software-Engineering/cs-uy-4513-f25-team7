# Quick Local Testing Guide

## Step 1: Setup (One Time)

```bash
# Install dependencies
bundle install

# Setup database
rails db:create db:migrate

# Or if database already exists:
rails db:migrate
```

## Step 2: Start Server

```bash
rails server
# or
rails s
```

Open browser: **http://localhost:3000**

## Step 3: Quick Manual Test (5 minutes)

### Test 1: Forum Page
1. Go to `/posts` or click "Forum" in nav
2. ✅ Should see forum page with search bar
3. ✅ Should see "New Post" button

### Test 2: Create Post
1. Click "New Post"
2. Fill in:
   - Title: "Test Post"
   - Post Type: "Thread"
   - Body: "This is a test"
   - Tags: "test, example"
3. Click "Create Post"
4. ✅ Should redirect to post page
5. ✅ Should see success message
6. ✅ Should see your post content
7. ✅ Should see tags (if tags table exists)

### Test 3: Voting (if enabled)
1. On a post page, look for ▲ and ▼ buttons
2. Click ▲ (upvote)
3. ✅ Score should increase
4. ✅ Should see "Upvoted!" message
5. Click ▼ (downvote)
6. ✅ Score should decrease

### Test 4: Tags
1. Click on a tag link
2. ✅ Should filter to show only posts with that tag
3. ✅ URL should have `?tag=test`

### Test 5: Search
1. Use search box on forum page
2. Type some text
3. Click "Search"
4. ✅ Should show filtered results

### Test 6: Comments
1. View a post
2. Scroll to comments section
3. Type a comment
4. Click "Post Comment"
5. ✅ Comment should appear

### Test 7: Pagination (if >10 posts)
1. Create 11+ posts
2. Go to forum index
3. ✅ Should see pagination controls at bottom
4. Click page 2
5. ✅ Should see different posts

## Step 4: Run Cucumber Tests

```bash
# Run all tests
bundle exec cucumber

# Or with progress output
bundle exec cucumber --format progress

# Run specific features
bundle exec cucumber features/forum_posts_and_comments.feature
bundle exec cucumber features/voting_system.feature
bundle exec cucumber features/advanced_tagging.feature
bundle exec cucumber features/pagination.feature
```

## Step 5: Check for Errors

### Browser Console (F12)
- Open Developer Tools (F12)
- Check Console tab
- ✅ Should see NO red errors
- ✅ No JavaScript errors about voting controller

### Rails Server Terminal
- Check the terminal where `rails s` is running
- ✅ Should see no SQL errors
- ✅ Should see no "table doesn't exist" errors
- ✅ Routes should work (check for 200 status codes)

## Step 6: Verify Features Work

### ✅ Voting System
- Vote buttons appear (if votes table exists)
- Clicking buttons works
- Score updates
- Flash messages appear

### ✅ Tagging System
- Tags appear on posts (if tags table exists)
- Tag links are clickable
- Tag filtering works
- Popular tags section shows (if tags exist)

### ✅ Pagination
- Pagination controls appear when >10 posts
- Can navigate between pages
- URL updates with page parameter

### ✅ Search & Filter
- Search box works
- Tag dropdown works (if tags exist)
- Combined search + tag filter works

## Common Issues & Fixes

### Issue: "Table doesn't exist" errors
**Fix:** Run migrations:
```bash
rails db:migrate
```

### Issue: Voting buttons don't appear
**Check:** Votes table exists?
```bash
rails console
> ActiveRecord::Base.connection.table_exists?('votes')
```

### Issue: Tags don't appear
**Check:** Tags table exists?
```bash
rails console
> ActiveRecord::Base.connection.table_exists?('tags')
```

### Issue: JavaScript errors
**Fix:** Hard refresh browser (Ctrl+F5 or Cmd+Shift+R)

### Issue: Styles not loading
**Fix:** Check if CSS file is being served, restart server

## Success Checklist

- [ ] Server starts without errors
- [ ] Can create posts
- [ ] Can view posts
- [ ] Voting works (if enabled)
- [ ] Tags work (if enabled)
- [ ] Search works
- [ ] Pagination works (if >10 posts)
- [ ] Comments work
- [ ] No browser console errors
- [ ] No server errors
- [ ] All Cucumber tests pass

## If Everything Works ✅

Your frontend is **100% ready** and compatible with main branch!

