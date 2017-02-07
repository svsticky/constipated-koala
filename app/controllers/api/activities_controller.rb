class Api::ActivitiesController < ApiController
  before_action :authorize, only: [:show]

  def index
    if params[:date].present?
      @activities = Activity.where('(end_date IS NULL AND start_date = ?) OR end_date <= ?', params[:date], params[:date]).order(:start_date).limit(params[:limit] ||= 10).offset(params[:offset] ||= 0)

    else
      @activities = Activity.where('(end_date IS NULL AND start_date >= ?) OR end_date >= ?', Date.today, Date.today).order(:start_date)
      @activities.limit!(params[:limit]).offset(params[:offset] ||= 0) if params[:limit].present?
    end
  end

  def show
    @activity = Activity.find_by_id! params[:id]
  end

  def advertisements
    @advertisements = Advertisement.all
  end

  def authorize
    # Either being logged in, or having a valid doorkeeper token is sufficient.
    # This replicates the content of the doorkeeper_authorize! before_action.
    @_doorkeeper_scopes = Doorkeeper.configuration.default_scopes

    if valid_doorkeeper_token? or user_signed_in?
      return
    end

    head :unauthorized
  end
end
