# Load the Rails application.
require_relative 'application'

if ENV['LOG_DIRECTORY'].present?
    Rails.logger = Logger.new File.open(ENV['LOG_DIRECTORY'], 'a')
end

# Initialize the Rails application.
Rails.application.initialize!
