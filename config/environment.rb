# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
ConstipatedKoala::Application.initialize!

# Custom configuration
ConstipatedKoala::Application.configure do
  config.mailgun = 'key-4bljpoyufuohbwptsdpgndhqmz1xxjq0'
end