class Api::ParticipantsController < ApiController
  before_action -> { doorkeeper_authorize! 'participant-read' }, only: :index
  before_action -> { doorkeeper_authorize! 'participant-write' }, only: [:create, :destroy]

  def index
    if params[:activity_id].present?
      @participants = Participant.where( :activity => Activity.find_by_id(params[:activity_id])).includes( :activity, :member )

    elsif params[:member_id].present?
      render :status => :unauthorized, :json => '' and return unless Authorization._member.id == params[:member_id]

      @participants = Participant.where( :member => Authorization._member ).includes( :activity, :member )
    else

      render :status => :bad_request
      return
    end
  end

  def create
    activity = Activity.find params[:activity_id]

    @participant = Participant.new( :member =>  Authorization._member, :activity => activity)
    @participant.save

    return unless params[:bank].present?

    @transaction = IdealTransaction.new(
      :description => activity.name,
      :amount => @participant.currency.to_f + Settings.mongoose_ideal_costs,
      :issuer => params[:bank],
      :type => 'ACTIVITIES',
      :member => @participant.member,
      :transaction_id => activity.id.to_a,
      :transaction_type => 'Activity' )

    @transaction.save
  end

  def destroy
    participant = Participant.find_by_id params[:participant_id]

    render :status => :locked, :json => '' and return if participant.activity.start_date >= Date.today
    render :status => :unauthorized, :json => '' and return if participant.member == Authorization._member

    respond_with participant.destroy
  end
end
