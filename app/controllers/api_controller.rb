class ApiController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session
  respond_to :json, :xml

  def current_user
    User.find_by_id(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end
end
