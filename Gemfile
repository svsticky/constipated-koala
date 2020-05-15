source 'https://rubygems.org'

gem 'mysql2', '0.5.1'
gem 'rails', '~> 6.0'

# use of Haml and rabl
gem 'haml'
gem 'rabl'

# assets and stuff
gem 'coffee-rails'
gem 'font_awesome5_rails'
gem 'sassc-rails'

# authentication gems
gem 'devise'
gem 'doorkeeper'
gem 'doorkeeper-openid_connect'

gem 'impressionist', :github => 'charlotte-ruby/impressionist'

# rests calls for mailgun
gem 'rest-client'

# search engine
gem 'fuzzily', :github => 'svsticky/fuzzily'
gem 'responders'

# pagination
gem 'will_paginate'
gem 'will_paginate-bootstrap4'

# settings cached in rails environment
gem 'image_processing'
gem 'rails-settings-cached', '~> 0.7'

# phone number validation
gem 'telephone_number'

gem 'i18n-js'

gem 'sidekiq'

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
  gem 'rubocop'
  gem 'spring'

  # i18n checks
  gem 'i18n-tasks', '~> 0.9.31'
end
