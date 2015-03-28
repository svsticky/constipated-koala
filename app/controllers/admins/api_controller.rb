class Admins::ApiController < ApplicationController
  protect_from_forgery except: [:list]
  before_filter :enable_cors, only: [:list]
  
  skip_before_action :authenticate_user!, only: [:list]
  skip_before_action :authenticate_admin!, only: [:list]

  respond_to :json, only: :list
  
  def list
    render :status => :ok, :json => Activity.where('(end_date IS NULL AND start_date >= ?) OR end_date >= ?', Date.today, Date.today ).select(:id, :name, :description, :start_date, :end_date, :poster_updated_at)\
      .map{ |item| (item.attributes.merge({ :poster => Activity.find(item.id).poster.url(:medium) }) if !item.poster_updated_at.nil?)}.compact.to_json
      
    # TODO add reclame
  end
end