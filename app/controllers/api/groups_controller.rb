class Api::GroupsController < ApplicationController
  before_action -> { doorkeeper_authorize! 'group-read' }

  def index
    respond_with Group.where( :category => params[:category]).order(:name) and return unless params[:category].nil?
    respond_with Group.all.order( :category, :name )
  end

  def show
    respond_with Group.find_by_id!(params[:id])
  end
end
