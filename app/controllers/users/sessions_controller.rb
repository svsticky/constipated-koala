#:nodoc:
class Users::SessionsController < Devise::SessionsController
  skip_before_action :authenticate_admin!, only: [:create, :destroy]

  # NOTE: overwrite create method, once a user is authenticated we can verify
  # it has worked, othersie we can create a fatal log rule.
  def create
    # perform default create from devise sessioncontroller
    super
    flash.delete(:notice) # remove "successfully signed in" message
  ensure
    # check if authentication succeeded, otherwise log failed attempt
    logger.fatal "[#{ Time.zone.now }] #{ I18n.t('activerecord.errors.failed_login') }; #{ request.remote_ip }; #{ request.filtered_parameters['user']['email'] }" if current_user.nil?
  end
end
