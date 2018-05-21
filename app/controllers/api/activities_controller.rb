class Api::ActivitiesController < ApiController
  include ActionController::Live
  before_action :authorize, only: [:show]

  def index
    if params[:date].present?
      @activities = Activity.where('(end_date IS NULL AND start_date = ?) OR end_date <= ?', params[:date], params[:date]).order(:start_date).limit(params[:limit] ||= 10).offset(params[:offset] ||= 0)

    else
      @activities = Activity.where('(end_date IS NULL AND start_date >= ?) OR end_date >= ?', Date.today, Date.today).order(:start_date).where(is_viewable: true)
      @activities.limit!(params[:limit]).offset(params[:offset] ||= 0) if params[:limit].present?
      @activities = @activities.select { |act| !act.ended? }
    end
  end

  def show
    @activity = Activity.find_by_id! params[:id]
  end

  def image
    @blob = Activity.find_by_id!(params[:activity_id]).poster.representation(resize: 'x1080')

    response.headers["Content-Type"] = @blob.blob.content_type || DEFAULT_SEND_FILE_TYPE
    response.headers["Content-Disposition"] = 'inline' || DEFAULT_SEND_FILE_DISPOSITION

    ActiveStorage::Blob.service.download @blob.key do |chunk|
      response.stream.write chunk
    end
  ensure
    response.stream.close
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
