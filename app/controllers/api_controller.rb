class ApiController < ApplicationController
  skip_before_action :verify_authenticity_token
  respond_to :json, :xml

  around_filter do |controller, action|
    begin
      Authorization._user = User.find_by_id(doorkeeper_token.resource_owner_id) if doorkeeper_token
      Authorization._client = Doorkeeper::Application.find_by_id(doorkeeper_token.application_id) if doorkeeper_token

      action.call
    ensure
      Authorization._clear!
    end
  end
end
