class Admins::ActivitiesController < ApplicationController

  def index    
    @activities = Activity.where("start_date >= ?", Date.start_studyyear).order(start_date: :desc)

    @detailed = (Activity.where("start_date <= ? AND activities.price IS NOT NULL", Date.today).joins(:participants).where(:participants => { :paid => false }).distinct \
      + Activity.where("start_date <= ? AND activities.price IS NULL", Date.today).joins(:participants).where('participants.paid IS FALSE AND participants.price IS NOT NULL').distinct).sort_by(&:start_date).reverse!
    
    @activity = Activity.new
  end

  def show
    @activity = Activity.find(params[:id])
    @recipients =  @activity.participants.order('members.first_name', 'members.last_name').joins(:member).where('participants.paid' => false).select(:id, :member_id, :first_name, :email)
  end

  def create
    @activity = Activity.new(activity_post_params)

    if(@activity.start_date == @activity.end_date)
      @activity.end_date = nil
    end

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
  
  private
  def activity_post_params
    params.require(:activity).permit( :name,
                                      :start_date,
                                      :end_date,
                                      :comments,
                                      :price,
                                      :poster)
  end
end
