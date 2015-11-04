class Api::MembersController < ApiController
  before_action -> { doorkeeper_authorize! 'member-read' }, only: [:index, :show]
  before_action -> { doorkeeper_authorize! 'member-write' }, only: :update

  def index
    members = Member.search( params[:search] ) unless params[:search].nil?
    members = Member.all.order(:last_name, :first_name).limit(params[:limit] ||= 50).offset(params[:offset] ||= 0) if params[:search].nil?

    members = Member.none if members.nil?
    respond_with members[params[:offset] ||= 0, params[:limit] ||= 50]
  end

  def show
    respond_with Member.find_by_id!(params[:id]), { :include => :educations }
  end

  def update
    # TODO rechten systeem?
    render :status => :unauthorized, :json => '' and return if params[:id].to_i != current_user.credentials.id

    member = Member.find_by_id(params[:id])
    render :status => :not_found, :json => '' and return if member.nil?

    begin
      member.update(member_post_params)
    rescue ActionController::UnpermittedParameters => e
      messages = Hash[e.params.map{ |param| [param,[I18n.t(:unpermitted, scope: 'activerecord.errors.models')]] }]

      # also check model for errors while we're are at it, after unpermitted params, model is not validated
      messages = messages.merge(member.errors.messages) unless member.valid?
      render :status => :unprocessable_entity, :json => messages
      return
    end
    respond_with member
  end

  def member_post_params
    params.require(:member).permit(:first_name,
                                   :infix,
                                   :last_name,
                                   :address,
                                   :house_number,
                                   :postal_code,
                                   :city,
                                   :phone_number,
                                   :email,
                                   :gender,
                                   :student_id,
                                   :birth_date,
                                   educations_attributes: [ :id, :study_id, :status, :start_date, :end_date, :_destroy ])
  end
end
