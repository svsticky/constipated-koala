class Api::ActivitiesController < ApiController
  before_action -> { doorkeeper_authorize! 'activity-read' }, only: :show

  def index
    @activities = Activity.all.order(:end_date, :start_date).limit(params[:limit] ||= 10).offset(params[:offset] ||= 0) and return if params[:date].nil?

    @activities =  Activity.where('(end_date IS NULL AND start_date >= ?) OR end_date >= ?', params[:date], params[:date] ).limit(params[:limit] ||= 10).offset(params[:offset] ||= 0)
  end

  def show
    @activity =  Activity.find_by_id!(params[:id])
  end

  def adverts
    @adverts = Advertisement.all.select(:id, :name, :poster_updated_at)
  end

end
