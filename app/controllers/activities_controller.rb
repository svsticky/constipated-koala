class ActivitiesController < ApplicationController

  def index
    @activities = Activity.all.order(start_date: :desc)
  end
  
  def show
    @activity = Activity.find(params[:id])
  end
  
  def new
  
  end
  
  def create
  
  end
  
  def edit
  
  end
  
  def update
    @activity = Activity.find(params[:id])
  end
end
