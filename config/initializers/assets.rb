# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = ConstipatedKoala::Application::VERSION

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
# Rails.application.config.assets.precompile += %w( admin.js admin.css )

# Assets for login pages and doorkeeper pages
Rails.application.config.assets.precompile += %w( doorkeeper.css )
Rails.application.config.assets.precompile += %w( doorkeeper.js )

# Assets for intro website
Rails.application.config.assets.precompile += %w( public.css )
Rails.application.config.assets.precompile += %w( public.js )
