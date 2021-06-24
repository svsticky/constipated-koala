source 'https://rubygems.org'

gem 'dotenv-rails'

gem 'mysql2', '0.5.1'
gem 'rails', '~> 6.0'

# use of Haml and rabl
gem 'haml'
gem 'rabl'

# assets and stuff
gem 'coffee-rails'
gem 'font_awesome5_rails'
gem 'sassc-rails'
gem 'webpacker'

# mimemagic
gem 'mimemagic', '0.3.9'

# authentication gems
gem 'devise'
gem 'doorkeeper'
gem 'doorkeeper-openid_connect'

gem 'impressionist', :github => 'charlotte-ruby/impressionist'

# rests calls for mailgun
gem 'rest-client'

gem 'responders'

# pagination
gem 'pagy'

# settings cached in rails environment
gem 'image_processing'
gem 'rails-settings-cached', '~> 0.7'

# phone number validation
gem 'telephone_number'

gem 'csv'
gem 'i18n-js'
gem 'sidekiq'

# Database
gem 'pg'

# Full text search
gem 'pg_search'

group :production, :staging do
  gem 'sentry-raven'
  gem 'uglifier'
  gem 'unicorn'
end

group :development, :test, :staging do
  gem 'faker'
end

group :development do
  gem 'listen'
  gem 'puma'

  gem 'byebug', platform: :mri
  gem 'web-console'

  # Added at 2018-01-12 12:01:35 +0100 by cdfa:
  gem 'i15r', '~> 0.5.5'
end

group :development, :test do
  gem 'brakeman'
  gem 'rubocop'
  gem 'spring'

  # i18n checks
  gem 'i18n-tasks', '~> 0.9.31'
end
