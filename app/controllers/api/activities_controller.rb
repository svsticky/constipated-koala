#:nodoc:
class Api::ActivitiesController < ApiController
  # doorkeeper_authorize! isn't used here so logged in users also have access
  # to activities. This is used to update the participant and reservists tables
  # when enrolling for an activity.
  before_action :authorize, only: [:show]

  def index
    if params[:date].present?
      @activities = Activity.where(
        '(end_date IS NULL AND start_date = ?) OR end_date <= ?',
        params[:date],
        params[:date]
      ).order(:start_date).limit(params[:limit] ||= 10).offset(params[:offset] ||= 0)
    else
      from = params[:from].present? ? Date.parse(params[:from]) : Date.today
      @activities = Activity.where('start_date >= ?', from)
                            .order(:start_date)
                            .where(is_viewable: true)

      # Allow nil to mean no limit on the end date
      @activities = @activities.where('end_date <= ?', Date.parse(params[:to])) if params[:to].present?

      @activities = @activities.limit!(params[:limit]).offset(params[:offset] ||= 0) if params[:limit].present?

      @activities = @activities.reject(&:ended?) if params[:from].blank?
      @activities
    end
  end

  def poster
    @activity = Activity.find(params[:activity_id])
    redirect_to(url_for(@activity.poster_representation))
  end

  def thumbnail
    @activity = Activity.find(params[:activity_id])
    redirect_to(url_for(@activity.thumbnail_representation))
  end

  def show
    @activity = Activity.find(params[:id])
  end

  private

  def authorize
    @_doorkeeper_scopes = Doorkeeper.configuration.default_scopes

    return if valid_doorkeeper_token? || user_signed_in?

    head(:unauthorized)
  end
end
