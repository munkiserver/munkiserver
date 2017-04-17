# Edit this Gemfile to bundle your application's dependencies.
source "https://rubygems.org"

gem "version_sorter"

gem "cancan"
gem "client_side_validations"
gem "execjs"
gem "highline"
gem "nokogiri"
gem "open_uri_redirections"
gem "paperclip"
gem "plist"
gem "rails", "3.2.22.1"
gem "sqlite3-ruby", :require => "sqlite3"
gem "whenever"
gem "will_paginate", "~> 3.0" # version added for rails 3 compatibility

gem "mysql2", "~> 0.3.20"

gem "dynamic_form" # enabling this should allow the removal of vendor/dynamic_form
gem "highcharts-rails", "~> 2.1.9"

gem "active_record_or"

gem "coveralls", require: false

gem "jquery-rails"
gem "jquery-ui-rails"

gem "ace-rails-ap"
gem "puma"
gem "redis-rails"

gem "dotenv-rails"
gem "rack-timeout"

gem "sidekiq"

group :development do
  gem "rails-erd"

  gem "bullet"
  gem "meta_request"
  gem "rubocop", "~> 0.48.1", require: false
end

group :test do
  gem "capybara", "~> 1.1.2"
  gem "database_cleaner"
  gem "factory_girl", "~> 3.3.0"
  gem "faker"
  gem "rspec-rails", "~> 2.14"
  gem "test-unit"
  gem "vcr", "~> 2.4.0"
  gem "webmock", "~> 1.8.7"
end

group :assets do
  gem "coffee-rails"
  gem "sass-rails"
  gem "uglifier"
end

gem "newrelic_rpm"

group :development, :test do
  gem "pry-rails"
end
