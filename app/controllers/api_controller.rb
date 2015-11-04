class ApiController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  respond_to :json, :xml

  # Moved the authentication requirement to the application controller
  before_action :authorize_read
  def authorize_read
    doorkeeper_authorize! :read
  end

  before_action :authorize_write, :only => [:create, :update, :destroy]
  def authorize_write
    doorkeeper_authorize! :write
  end

  def current_user
    User.find_by_id(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end
end
