source 'https://rubygems.org'

gem 'dotenv-rails'

gem 'rails', '~> 6.1'

# use of Haml and rabl
gem 'haml'
gem 'rabl'

# assets and stuff
gem 'coffee-rails'
gem 'font_awesome5_rails'
gem 'sassc-rails'
gem 'webpacker', '6.0.0.rc.6'

# mimemagic
gem 'mimemagic', '0.3.9'

# authentication gems
gem 'devise'
gem 'doorkeeper'
gem 'doorkeeper-openid_connect'

gem 'impressionist'

# rests calls for mailgun
gem 'rest-client'

# mollie
gem 'mollie-api-ruby'

gem 'responders'

# pagination
gem 'pagy'

# settings cached in rails environment
gem 'image_processing'
gem 'rails-settings-cached', '~> 0.7'

gem 'psych', '< 4'

# phone number validation
gem 'telephone_number'

gem 'csv'
gem 'i18n-js', '~> 3.9'
gem 'sidekiq', '~> 6.4'

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
  gem 'faker', '~> 2.19'
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
  gem 'haml-lint'
  gem 'rubocop'
  gem 'rubocop-rails'
  gem 'spring'

  # i18n checks
  gem 'i18n-tasks', '~> 0.9.31'
end
