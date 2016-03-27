# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.

# Assets for login pages and doorkeeper pages
Rails.application.config.assets.precompile += %w( doorkeeper.css )
Rails.application.config.assets.precompile += %w( doorkeeper.js )

# Assets for intro website
Rails.application.config.assets.precompile += %w( public.css )
Rails.application.config.assets.precompile += %w( public.js )
