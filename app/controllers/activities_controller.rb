class ActivitiesController < ApplicationController

  def index
    @activities = Activity.all.order(start_date: :desc)
    @activity = Activity.new
  end
  
  def show
    @activity = Activity.find(params[:id])
    @recipients =  @activity.participants.order('members.first_name', 'members.last_name').joins(:member).where('participants.paid' => false).select(:id, :member_id, :first_name, :email)
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
  
  def update
    @activity = Activity.find(params[:id])

    if @activity.update(activity_post_params)  
      redirect_to @activity
    else
      render 'show'
    end
  end
  
	def destroy
		@activity = Activity.find(params[:id])
		@activity.destroy

		redirect_to activities_path
	end

  def setOrganiser
    @activity = Activity.find(params[:id])
    @activityId = params[:searchId]
    if @activityId == 'NIL'
      @activity.update_attributes(:committee => NIL)
    else
      @activity.update_attributes(:committee => Committee.find(@activityId))
    end

    if @activity.save
      render :status => :ok, :json => @activity.committee
    else
      respond_with @activity.errors.full_messages
    end
  end
  
  private
  def activity_post_params
    params.require(:activity).permit( :name,
                                      :start_date,
                                      :end_date,
                                      :comments,
                                      :price)
  end
end
