class Api::ParticipantsController < ApiController
  before_action -> { doorkeeper_authorize! 'participant-read' }, only: :index
  before_action -> { doorkeeper_authorize! 'participant-write' }, only: [:create, :destroy]

  def index
    respond_with Participant.where( :member => current_user.credentials ).includes(:activity).order('activities.end_date', 'activities.start_date').limit(params[:limit] ||= 10).offset(params[:offset] ||= 0), { :include => :activity }
  end

  def create
    activity = Activity.find(params[:activity])
    participant = Participant.new( :member =>  current_user.credentials, :activity => activity)

    participant.save
    respond_with participant
  end

  def destroy
    participant Participant.find_by_id(params[:id])
    render :status => :locked, :json => '' and return if participant.activity.start_date >= Date.today
    respond_with participant.destroy
  end
end
