source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{ repo_name }/#{ repo_name }" unless repo_name.include?('/')
  "https://github.com/#{ repo_name }.git"
end

gem 'mysql2'
gem 'rails'

# use of Haml and rabl
gem 'haml'
gem 'rabl'

# assets and stuff
gem 'coffee-rails'
gem 'sass-rails'

# authentication gems
gem 'devise'
gem 'doorkeeper'
gem 'doorkeeper-openid_connect'

gem 'impressionist'

# rests calls for mailgun
gem 'rest-client'

# search engine
gem 'fuzzily', :github => 'svsticky/fuzzily'
gem 'responders'

# settings cached in rails environment
gem 'rails-settings-cached'

# Paperclip easy file upload
gem 'paperclip'
gem 'terrapin'

gem 'chartkick'
gem 'groupdate'

# Pagination
gem 'will_paginate', '~> 3.1.0'
gem 'bootstrap-will_paginate'

group :production, :staging do
  gem 'sentry-raven'
  gem 'unicorn'
  gem 'uglifier'
end

group :development, :test, :staging do
  gem 'faker', '>= 1.8.4'
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
end
