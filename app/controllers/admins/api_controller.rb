class Admins::ApiController < ApplicationController
  protect_from_forgery except: [:radio]
  before_filter :enable_cors, only: [:radio]

  skip_before_action :authenticate_user!, only: [:radio]
  skip_before_action :authenticate_admin!, only: [:radio]

  respond_to :json, only: :radio

  def radio
    render :status => :ok, :json => Advertisement.list
  end
end
