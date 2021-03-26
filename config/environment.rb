# Load the Rails application.
require_relative 'application'

Rails.logger = Logger.new File.open(ENV['LOG_DIRECTORY'], 'a') if ENV['LOG_DIRECTORY'].present?

# Initialize the Rails application.
Rails.application.initialize!
