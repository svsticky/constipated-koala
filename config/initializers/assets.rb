# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = ConstipatedKoala::Application::VERSION

# Add Yarn node_modules folder to the asset load path.
Rails.application.config.assets.paths << Rails.root.join('node_modules')
Rails.application.config.assets.precompile << /\.(?:svg|woff|woff2|ttf)\z/

# Precompile additional assets; application.js, application.css, and all
# non-JS/CSS in the app/assets folder are already added.

# Assets for member part of koala
Rails.application.config.assets.precompile += %w[members.css members.js]

# Assets for login pages and doorkeeper pages
Rails.application.config.assets.precompile += %w[doorkeeper.css doorkeeper.js]

# Assets for intro website
Rails.application.config.assets.precompile += %w[intro.css intro.js]

# Assets for public pages including token pages
Rails.application.config.assets.precompile += %w[public.css public.js]

# added view paths for rabl
Rabl.configure do |config|
  config.view_paths = [Rails.root.join('app', 'views')]
end
