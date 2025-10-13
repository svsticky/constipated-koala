Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.
  config.log_level = :debug

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  config.action_controller.perform_caching = false
  config.cache_store = :null_store

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.perform_caching = false
  config.action_mailer.delivery_method = :test

  config.action_mailer.default_url_options = {
    host: 'koala.rails.local',
    port: 3000
  }

  Rails.application.routes.default_url_options = {
    host: 'koala.rails.local',
    port: 3000
  }

  config.hosts << 'koala.rails.local'
  config.hosts << 'wordlid.rails.local'
  config.hosts << 'signup.rails.local'
  config.hosts << 'join.rails.local'
  config.hosts << 'leden.rails.local'
  config.hosts << 'members.rails.local'

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true
  config.serve_static_assets = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true
  config.assets.digest = false

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # Raises error for missing translations
  config.i18n.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  # for development only, debugging with test environment of radio
  config.action_dispatch.default_headers.merge!(
    'Access-Control-Allow-Origin' => 'http://radio.rails.local:3001',
    'Access-Control-Request-Method' => '*'
  )

  if Rails.root.join('tmp/caching-dev.txt').exist?
    config.action_controller.perform_caching = true
    config.static_cache_control = "public, max-age=172800"
    config.cache_store = :file_store, Rails.root.join('tmp/cache')
  else
    config.action_controller.perform_caching = false
    config.cache_store = :null_store
  end
end
