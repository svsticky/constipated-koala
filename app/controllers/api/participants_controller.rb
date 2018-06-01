#:nodoc:
class Api::ParticipantsController < ApiController
  before_action -> { doorkeeper_authorize! 'participant-read' }, only: :index
  before_action -> { doorkeeper_authorize! 'participant-write' }, only: [:create, :destroy, :update]

  def index
    if params[:activity_id].present?
      @participants = Participant.where(:activity => Activity.find_by_id(params[:activity_id])).includes(:activity, :member)

    elsif params[:member_id].present?
      head(:unauthorized) && return unless Authorization._member.id == params[:member_id].to_i
      @participants = Participant.where(:member => Authorization._member).includes(:activity, :member)

    else
      head :bad_request
      return
    end
  end

  def create
    @participant = Participant.new(:member => Authorization._member, :activity => Activity.find_by_id!(params[:activity_id]))
    head(:bad_request) && return unless @participant.save
    render :status => :created
  end

  def hook
    transaction = IdealTransaction.find_by_uuid! params[:uuid]

    head(:bad_request) && return unless transaction.type == 'ACTIVITIES'
    redirect_to(transaction.redirect_uri) && return unless transaction.status == 'SUCCESS'

    transaction.transaction_id.each do |activity|
      participant = Participant.find_by_member_id_and_activity_id transaction.member.id, activity
      participant.update_attributes :paid => true
    end

    redirect_to transaction.redirect_uri
  end

  def update; end

  def destroy
    participant = Participant.find_by_member_id_and_activity_id! Authorization._member.id, params[:activity_id]

    head(:locked) && return if participant.paid
    head(:locked) && return if participant.activity.start_date <= Date.today

    participant.destroy!
    head :no_content
  end
end
