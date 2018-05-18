# encoding: UTF-8
source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'rails'
gem 'mysql2'

# use of Haml and rabl
gem 'haml'
gem 'rabl'

# assets and stuff
gem 'sass-rails'
gem 'coffee-rails'

# authentication gems
gem 'devise', :github => 'plataformatec/devise'
gem 'doorkeeper'

gem 'impressionist'

# rests calls for mailgun
gem 'rest-client'

# search engine
gem 'fuzzily', :github => 'svsticky/fuzzily'
gem 'responders'

# settings cached in rails environment
gem 'rails-settings-cached'

# Paperclip easy file upload to S3
gem 'paperclip'
gem 'cocaine', '0.3.2'

group :production, :staging do
  gem 'sentry-raven'
  gem 'unicorn'
  gem 'uglifier'
end

group :development, :test, :staging do
  gem 'faker', '>= 1.8.4'
end

group :development do
  gem 'puma'
  gem 'listen'

  gem 'web-console'
  gem 'byebug', platform: :mri
end

group :development, :test do
  gem 'rubocop', '~> 0.50.0'
  gem 'spring'
end
