class Api::ActivitiesController < ApiController
  before_action -> { doorkeeper_authorize! 'activity-read' }, only: [ :show ]

  def index # TODO index also activity-read
    if params[:date].present?
      @activities = Activity.where('(end_date IS NULL AND start_date = ?) OR end_date <= ?', params[:date], params[:date] ).order( :start_date ).limit( params[:limit] ||= 10 ).offset( params[:offset] ||= 0 )

    else
      @activities = Activity.where('(end_date IS NULL AND start_date >= ?) OR end_date >= ?', Date.today, Date.today ).order( :start_date )
      @activities.limit!( params[:limit] ).offset( params[:offset] ||= 0 ) if params[:limit].present?
    end
  end

  def show
    @activity =  Activity.find_by_id! params[:id]
  end

  def advertisements
    @advertisements = Advertisements.all
  end
end
