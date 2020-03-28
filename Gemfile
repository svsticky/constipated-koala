source 'https://rubygems.org'

# please use gem's only for ruby functionalities
# use yarn for custom javascript or css libraries

gem 'mysql2', '0.5.1'
gem 'rails', '~> 6.0'

# use of Haml and rabl
gem 'haml'
gem 'rabl'

# assets and stuff
gem 'sassc-rails'
gem 'sprockets', '~> 3.0' # TODO remove this line and update to v4
gem 'pagy'

# authentication gems
gem 'devise'
gem 'doorkeeper'
gem 'doorkeeper-openid_connect'

gem 'impressionist'

# rests calls for mailgun
gem 'rest-client'
gem 'sidekiq'

# search engine
gem 'fuzzily', :github => 'svsticky/fuzzily'
gem 'responders'

# settings cached in rails environment
gem 'image_processing'
gem 'rails-settings-cached', '~> 0.7'



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

  gem 'i15r'
end

group :development, :test do
  gem 'rubocop'
  gem 'spring'
end
