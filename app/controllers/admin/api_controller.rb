#:nodoc:
class Admin::ApiController < ApplicationController
  protect_from_forgery except: [:activities, :advertisements]

  skip_before_action :authenticate_user!, only: [:activities, :advertisements]
  skip_before_action :authenticate_admin!, only: [:activities, :advertisements]

  respond_to :json, only: [:activities, :advertisements]

  # are these functions even used? I can't find them in routes, I suggest moving it the controllers/api
  def activities
    render :status => :ok,
           :json => Activity.list.only(:name, :start_date, :end_date, :poster)
  end

  def advertisements
    render :status => :ok, :json => Advertisement.list.only(:poster)
  end
end
