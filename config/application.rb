require_relative 'boot'
require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, :staging or :production.
Bundler.require(*Rails.groups)

module ConstipatedKoala
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    VERSION = '1.7.7'

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Amsterdam'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]
    config.i18n.default_locale = :nl
    config.i18n.fallbacks = true
    config.i18n.fallbacks = [:nl, :en]

    # Set layout for controllers from gems, own controllers set the alternative layout
    # in the controller itself, for example Members::RegistrationsController
    config.to_prepare do
      Devise::SessionsController.layout 'doorkeeper'
      Devise::RegistrationsController.layout 'doorkeeper'
      Devise::ConfirmationsController.layout 'doorkeeper'
      Devise::UnlocksController.layout 'doorkeeper'
      Devise::PasswordsController.layout 'doorkeeper'
      Doorkeeper::AuthorizationsController.layout 'doorkeeper'
    end

    # Custom configuration
    config.mailgun = ENV['MAILGUN_TOKEN']
    config.checkout = ENV['CHECKOUT_TOKEN']

    config.action_dispatch.rescue_responses = {
      'ActiveRecord::RecordNotFound'                => :not_found,
      'ActiveRecord::RecordInvalid'                 => :bad_request,
      'ActiveRecord::RecordNotUnique'               => :conflict
    }
  end
end
