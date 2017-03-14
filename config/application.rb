require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ConstipatedKoala
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    VERSION = '1.3.0'

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Amsterdam'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]
    config.i18n.default_locale = :nl
    config.i18n.fallbacks = true
    config.i18n.fallbacks = [:nl, :en]

    config.to_prepare do
      Devise::SessionsController.layout 'doorkeeper'
      Devise::RegistrationsController.layout 'doorkeeper'
      Devise::ConfirmationsController.layout 'doorkeeper'
      Devise::UnlocksController.layout 'doorkeeper'
      Devise::PasswordsController.layout 'doorkeeper'

      Doorkeeper::AuthorizationsController.layout 'doorkeeper'
      Users::RegistrationsController.layout 'doorkeeper'
      Users::PublicController.layout false
    end

    config.action_dispatch.rescue_responses = {
      'ActiveRecord::RecordNotFound'                => :not_found,
      'ActiveRecord::RecordInvalid'                 => :bad_request,
      'ActiveRecord::RecordNotUnique'               => :conflict
    }
  end
end
