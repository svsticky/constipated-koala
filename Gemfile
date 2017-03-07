# encoding: UTF-8
source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails'

# Use mysql as the production database
gem 'mysql2'

# authentication gems
gem 'devise'
gem 'doorkeeper'

# logging
gem 'impressionist'

# RestClient for sending mail using mailgun
gem 'rest-client'

# new search engine
gem 'fuzzily'

# Use SCSS for stylesheets, sprockets for assets
gem 'sprockets', '~> 2.11.0'
gem 'sass-rails'

# use of Haml and rabl
gem 'haml'
gem 'rabl'

# Gem voor html5 stubs met form features
gem 'modernizr-rails'

# Use for javascript and libraries
gem 'execjs'
gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
gem 'responders'

# settings cached in rails environment
gem 'rails-settings-cached'

# Paperclip easy file upload to S3
gem 'paperclip'

# fancy JS alert and confirm
gem 'sweetalert-rails'

# Clipboard: Saved text to clipboard
gem 'clipboard-rails'

group :production do
  gem 'unicorn'
  gem 'aws-sdk', '~> 1.5.7'
  gem 'uglifier'
end

group :development do
  gem 'web-console'
  gem 'spring'
  gem 'faker'
end

group :test do
  gem 'spring'
  gem 'faker'
end
