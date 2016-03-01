# encoding: UTF-8
source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 4.1.1'

# authentication gem
gem 'devise', '~> 3.2.4'

# logging
gem 'impressionist'

# use of Haml
gem 'haml'

# RestClient for sending mail using mailgun
gem 'rest-client'

# Gem voor html5 stubs met form features
gem 'modernizr-rails'

# Paperclip easy file upload to S3
gem 'paperclip'

# Use mysql as the production database
gem 'mysql2', '~> 0.3.16'

# Use SCSS for stylesheets
gem 'sass-rails'

# new search engine
gem 'fuzzily'

# Use for javascript
gem 'execjs'
gem 'nokogiri'

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder'

# settings cached in rails environment
gem 'rails-settings-cached'

group :production do
  gem 'unicorn'
  gem 'aws-sdk', '~> 1.5.7'

  # Use Uglifier as compressor for JavaScript assets
  gem 'uglifier'
end

group :development, :test do
  gem 'faker'
end
