class ActivitiesController < ApplicationController

  def index
    @activities = Activity.all.order(start_date: :desc)
    @activity = Activity.new
  end
  
  def show
    @activity = Activity.find(params[:id])
  end
  
  def create
    @activity = Activity.new(activity_post_params)   

    if @activity.save
      redirect_to @activity
    else
      @activities = Activity.all.order(start_date: :desc)
      render 'index'
    end
  end
  
  def edit
  
  end
  
  def update
    @activity = Activity.find(params[:id])
  end
  
  private
  def activity_post_params
    params.require(:activity).permit( :name,
                                      :start_date,
                                      :end_date,
                                      :price)
  end
end
