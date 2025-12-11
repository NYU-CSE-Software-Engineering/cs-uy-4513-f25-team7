# Heroku Deployment & Testing Guide

## Quick Deploy to Heroku

### Prerequisites
1. Heroku account (free tier works)
2. Heroku CLI installed: https://devcenter.heroku.com/articles/heroku-cli

### Step 1: Login to Heroku
```bash
heroku login
```

### Step 2: Create Heroku App
```bash
# Create a new app (or use existing)
heroku create your-app-name

# Or if you already have an app:
heroku git:remote -a your-app-name
```

### Step 3: Set Ruby Version
```bash
# Ensure .ruby-version exists (should be 3.4.6)
heroku buildpacks:set heroku/ruby
```

### Step 4: Deploy Your Branch
```bash
# Push your integration-features branch to Heroku
git push heroku feature/integration-features:main

# Or if deploying from current branch:
git push heroku integration-features:main
```

### Step 5: Run Migrations
```bash
# Heroku will auto-run migrations from Procfile, but you can also run manually:
heroku run rails db:migrate
```

### Step 6: Open Your App
```bash
heroku open
```

Your app will be live at: `https://your-app-name.herokuapp.com`

## Testing on Heroku

### 1. Manual Testing
Visit your Heroku URL and test:
- ✅ Forum page loads
- ✅ Create posts with tags
- ✅ Voting works
- ✅ Tag filtering works
- ✅ Search works
- ✅ Pagination works
- ✅ Comments work

### 2. Run Cucumber Tests on Heroku
```bash
# Run tests in Heroku environment
heroku run bundle exec cucumber

# Or run specific features
heroku run bundle exec cucumber features/voting_system.feature
heroku run bundle exec cucumber features/advanced_tagging.feature
heroku run bundle exec cucumber features/pagination.feature
```

### 3. Check Logs
```bash
# View real-time logs
heroku logs --tail

# Check for errors
heroku logs --tail | grep -i error
```

### 4. Rails Console on Heroku
```bash
# Open Rails console
heroku run rails console

# Test in console:
> Post.count
> Tag.count
> ActiveRecord::Base.connection.table_exists?('votes')
> ActiveRecord::Base.connection.table_exists?('tags')
```

## Common Heroku Commands

```bash
# View app info
heroku info

# Check database
heroku pg:info

# Restart app
heroku restart

# Scale dynos (if needed)
heroku ps:scale web=1

# View config vars
heroku config

# Set environment variables (if needed)
heroku config:set ADMIN_SECRET_CODE=pokeforum2024
```

## Troubleshooting

### Issue: Build fails
**Check:** 
```bash
heroku logs --tail
```
Look for gem installation errors or migration issues.

### Issue: Database errors
**Fix:**
```bash
heroku run rails db:migrate
heroku restart
```

### Issue: Assets not loading
**Fix:**
```bash
# Precompile assets
heroku run rails assets:precompile
heroku restart
```

### Issue: App crashes
**Check logs:**
```bash
heroku logs --tail
```

## Testing Checklist on Heroku

- [ ] App deploys successfully
- [ ] Database migrations run
- [ ] Home page loads
- [ ] Forum page loads (`/posts`)
- [ ] Can create posts
- [ ] Voting buttons appear and work
- [ ] Tags appear and are clickable
- [ ] Tag filtering works
- [ ] Search works
- [ ] Pagination appears (if >10 posts)
- [ ] Comments can be added
- [ ] All Cucumber tests pass
- [ ] No errors in logs

## Advantages of Testing on Heroku

✅ **No Windows bundle install issues** - Heroku handles all gem compilation
✅ **Production-like environment** - Tests in real deployment conditions
✅ **PostgreSQL database** - Matches production setup
✅ **Easy to share** - Share URL with teammates/instructors
✅ **Automatic builds** - Can set up CI/CD

## Quick Deploy Script

Save this as `deploy.sh`:
```bash
#!/bin/bash
git push heroku feature/integration-features:main
heroku run rails db:migrate
heroku restart
heroku open
```

Then run:
```bash
chmod +x deploy.sh
./deploy.sh
```

## Your App is Ready!

Once deployed, your Heroku URL will have:
- ✅ All frontend features (voting, tagging, pagination)
- ✅ All defensive checks for compatibility
- ✅ Production-ready code
- ✅ Full test suite available

Test everything on Heroku - it's the best way to verify everything works in a production environment!

