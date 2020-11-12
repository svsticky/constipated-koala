# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = ConstipatedKoala::Application::VERSION

# Add Yarn node_modules folder to the asset load path.
Rails.application.config.assets.paths << ENV['NODE_PATH'].split(':')[0]

# added view paths for rabl
Rabl.configure do |config|
  config.view_paths = [Rails.root.join('app', 'views')]
end
