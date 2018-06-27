#:nodoc:
class Api::MembersController < ApiController
  before_action -> { doorkeeper_authorize! 'member-read' }, only: [:index, :show]

  def index
    @members = Member.all.order(:last_name, :first_name).offset(params[:offset] ||= 0).limit(params[:limit] ||= 20)
  end

  def show
    @member = Member.find_by_id!(params[:id])
  end
end
