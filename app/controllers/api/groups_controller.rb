class Api::GroupsController < ApiController
  before_action -> { doorkeeper_authorize! 'group-read' }, only: [:index, :show]

  def index #TODO filter members on year
    @groups =  Group.where( :category => params[:category]).order(:name) and return unless params[:category].nil?
    @groups =  Group.all.order( :category, :name )
  end

  def show #TODO filter activities and members on year
    @group = Group.find_by_id!(params[:id])
  end
end
