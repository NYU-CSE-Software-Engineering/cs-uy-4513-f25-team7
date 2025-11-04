source "https://rubygems.org"

ruby "3.3.8"

# Core
gem "rails", "~> 7.1.5", ">= 7.1.5.2"
gem "puma", ">= 5.0"
gem "sqlite3", ">= 1.4"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "jbuilder"
gem "sprockets-rails"
gem "bootsnap", require: false
gem "tzinfo-data", platforms: %i[windows jruby]
gem "devise"
gem "devise-two-factor"


# Auth & misc (you had these)
gem "bcrypt", "~> 3.1"
gem "rotp", "~> 6.3"
gem "omniauth"
gem "omniauth-google-oauth2"

group :development, :test do
  gem "debug", platforms: %i[mri windows]
  gem "rspec-rails"
  gem "rspec-expectations"
  gem "capybara"
end

group :development do
  gem "web-console"
  gem "spring"
end

group :test do
  gem "cucumber-rails", require: false
  gem "selenium-webdriver"
  gem "database_cleaner-active_record", "~> 2.0"
  gem "shoulda-matchers", "~> 6.0"
end
