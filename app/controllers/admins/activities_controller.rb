class Admins::ActivitiesController < ApplicationController
  protect_from_forgery except: [:list]
  before_filter :enable_cors, only: [:list]
  
  skip_before_action :authenticate_user!, only: [:list]
  skip_before_action :authenticate_admin!, only: [:list]

  respond_to :json, only: :list

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
    @activity = Activity.new(activity_post_params.except(:_destroy))

    if(@activity.start_date == @activity.end_date)
      @activity.end_date = nil
    end

    if @activity.save
      redirect_to @activity
    else
      @activities = Activity.all.order(start_date: :desc)
      
      @detailed = (Activity.where("start_date <= ? AND activities.price IS NOT NULL", Date.today).joins(:participants).where(:participants => { :paid => false }).distinct \
        + Activity.where("start_date <= ? AND activities.price IS NULL", Date.today).joins(:participants).where('participants.paid IS FALSE AND participants.price IS NOT NULL').distinct).sort_by(&:start_date).reverse!
    
      render 'index'
    end
  end
  
  def update
    @activity = Activity.find(params[:id])
    params = activity_post_params
    
    # removing the images from the S3 storage
    if params[:_destroy] == 'true'
      logger.debug 'remove poster from activity'
      params[:poster] = nil
    end

    if @activity.update(params.except(:_destroy)) 
      redirect_to @activity
    else
      @recipients =  @activity.participants.order('members.first_name', 'members.last_name').joins(:member).where('participants.paid' => false).select(:id, :member_id, :first_name, :email)
      render 'show'
    end
  end
  
  def destroy
    @activity = Activity.find(params[:id])
    @activity.destroy

    redirect_to activities_path
  end
	
  def list
    render :status => :ok, :json => Activity.where('start_date > ?', Date.today).select(:id, :name, :description, :start_date, :end_date, :poster_updated_at)\
      .map{ |item| (item.attributes.merge({ :poster => Activity.find(item.id).poster.url(:medium) }) if !item.poster_updated_at.nil?)}.compact.to_json
  end
  
  private
  def activity_post_params
    params.require(:activity).permit( :name,
                                      :description,
                                      :start_date,
                                      :end_date,
                                      :comments,
                                      :price,
                                      :poster,
                                      :_destroy)
  end
end
