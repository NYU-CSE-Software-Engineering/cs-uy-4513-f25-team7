source "https://rubygems.org"

ruby "3.3.8"

# --- Core app gems ---
gem "rails", "~> 7.1.5", ">= 7.1.5.2"
gem "puma", ">= 5.0"
gem "sqlite3", ">= 1.4"
gem "sprockets-rails"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "jbuilder"
gem "tzinfo-data", platforms: %i[windows jruby]
gem "bootsnap", require: false

# Auth/2FA and OAuth
gem "bcrypt", "~> 3.1"
gem "rotp", "~> 6.3"
gem "omniauth"
gem "omniauth-google-oauth2"
gem "devise", "~> 4.9"

group :development, :test do
  # Test frameworks
  gem "rspec-rails", "~> 7.1"
  gem "cucumber-rails", require: false
  gem "capybara", "~> 3.40"

  # Useful expectations when writing plain Ruby tests/helpers
  gem "rspec-expectations"

  # Debugger
  gem "debug", platforms: %i[mri windows]
end

group :test do
  # Clean DB between scenarios (AR adapter)
  gem "database_cleaner-active_record", "~> 2.0"

  # For JS/system features (optional; keep if you’ll test JS)
  gem "selenium-webdriver"
end

group :development do
  gem "web-console"
  gem "spring"  # optional; safe to keep, CI won’t load it
end
