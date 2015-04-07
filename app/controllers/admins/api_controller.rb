class Admins::ApiController < ApplicationController
  protect_from_forgery except: [:list]
  before_filter :enable_cors, only: [:list]
  
  skip_before_action :authenticate_user!, only: [:list]
  skip_before_action :authenticate_admin!, only: [:list]

  respond_to :json, only: :radio
  
  def radio
    render :status => :ok, :json => Advertisement.list
  end
end