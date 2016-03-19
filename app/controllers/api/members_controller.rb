class Api::MembersController < ApiController
  before_action -> { doorkeeper_authorize! 'member-read' }, only: [:index, :show]

  def index
    if params[:search].present?
      @members = Member.search( params[:search] )[params[:offset] ||= 0, params[:limit] ||= 20]

    elsif params[:student].present?
      @members = Member.find_by_student_id! params[:student]

    else
      @members = Member.all.order(:last_name, :first_name).offset(params[:offset] ||= 0).limit(params[:limit] ||= 20)
    end
  end

  def show
    @member = Member.find_by_id!(params[:id])
  end
end
