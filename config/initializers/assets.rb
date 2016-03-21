# Be sure to restart your server when you modify this file

# Version of your assets, change this if you want to expire all your assets
Rails.application.config.assets.version = '0.1'

# Precompile additional assets
Rails.application.config.assets.precompile += %w( *.css *.js )
Rails.application.config.assets.precompile += %w( */*.css */*.js )
