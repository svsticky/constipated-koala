#:nodoc:
class Users::SessionsController < Devise::SessionsController
  skip_before_action :authenticate_admin!, only: [:create, :destroy]

  # NOTE overwrite create method, once a user is authenticated we can verify
  # it has worked, othersie we can create a fatal log rule.
  def create
    # TODO: if account not confirmed, resend confirmation mail

    # perform default create from devise sessioncontroller
    super
  ensure
    # check if authentication succeeded, otherwise log failed attempt
    logger.fatal "[#{ Time.zone.now }] failed login attempt; #{ request.remote_ip }; #{ request.filtered_parameters['user']['email'] }" if current_user.nil?
  end
end
