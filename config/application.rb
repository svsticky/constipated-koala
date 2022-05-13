require_relative 'boot'
require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, :staging or :production.
Bundler.require(*Rails.groups)

Webpacker::Compiler.env["TAILWIND_MODE"] = "build"

#:nodoc:
module ConstipatedKoala
  #:nodoc:
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    VERSION = '2.15.0'.freeze

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Amsterdam'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]
    config.i18n.default_locale = :nl
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

    config.active_job.queue_adapter = :sidekiq

    # Enable raw sql in database migrations
    config.active_record.schema_format = :sql

    # Custom configuration
    config.mailgun = ENV['MAILGUN_TOKEN']
    config.checkout = ENV['CHECKOUT_TOKEN']

    config.mailchimp_interests = {
      alv: ENV['MAILCHIMP_ALV_ID'],
      business: ENV['MAILCHIMP_BUSINESS_ID'],
      mmm: ENV['MAILCHIMP_MMM_ID'],
      lectures: ENV['MAILCHIMP_LECTURES_ID'],
      teacher: ENV['MAILCHIMP_TEACHER_ID']
    }

    config.mailchimp_tags = ["gratie", "alumni"]

    config.action_dispatch.rescue_responses = {
      'ActiveRecord::RecordNotFound' => :not_found,
      'ActiveRecord::RecordInvalid' => :bad_request,
      'ActiveRecord::RecordNotUnique' => :conflict
    }

    # Store files locally.
    config.active_storage.service = :local

    # Generate translations.json
    config.middleware.use I18n::JS::Middleware
  end
end
