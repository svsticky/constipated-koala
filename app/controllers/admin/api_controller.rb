#:nodoc:
class Admin::ApiController < ApplicationController
  protect_from_forgery except: [:activities]

  skip_before_action :authenticate_user!, only: [:activities]
  skip_before_action :authenticate_admin!, only: [:activities]

  respond_to :json, only: [:activities]

  # are these functions even used? I can't find them in routes, I suggest moving it the controllers/api
  def activities
    render :status => :ok,
           :json => Activity.list.only(:name, :start_date, :end_date, :poster)
  end
end
