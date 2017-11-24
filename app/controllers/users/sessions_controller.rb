class Users::SessionsController < Devise::SessionsController
  # NOTE overwrite create method, once a user is authenticated we can verify
  # it has worked, othersie we can create a fatal log rule.
  def create
    begin
      # perform default create from devise sessioncontroller
      super
    ensure
      # check if authentication succeeded, otherwise log failed attempt
      return unless current_user.nil?
      logger.fatal "[#{Time.zone.now}] failed login attempt; #{request.remote_ip}; #{request.filtered_parameters['user']['email']}"
    end
  end
end
