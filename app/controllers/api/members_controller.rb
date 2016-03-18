class Api::MembersController < ApiController
  before_action -> { doorkeeper_authorize! 'member-read' }, only: [:index, :show]

  def index
    members = Member.search( params[:search] ) unless params[:search].nil?
    members = Member.all.order(:last_name, :first_name).limit(params[:limit] ||= 50).offset(params[:offset] ||= 0) if params[:search].nil?
    @members =  members[params[:offset] ||= 0, params[:limit] ||= 50]
  end

  def show
    @member = Member.find_by_id!(params[:id])
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
