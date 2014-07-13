class ActivitiesController < ApplicationController

  def index
    @activities = Activity.all    
  end
  
  def show
    @activity = Activity.find(params[:id])
  end
  
  def new
  
  end
  
  def create
  
  end
  
  def update
    @activity = Activity.find(params[:id])
  end
end
