class Admin::GroupsController < ApplicationController
  impressionist :actions => [ :create, :update ]

  def index
    @groups = Group.all.order( :category, :name )
    @group = Group.new
  end

  def show
    @groups = Group.all.order( :category, :name )
    @group = Group.find_by_id params[:id]
  end

  def create
    @group = Group.new group_params

    if @group.save
      redirect_to @group
    else
      @groups = Group.all.order( :category, :name )
      render 'show'
    end
  end

  def update
    @group = Group.find_by_id params[:id]

    if @group.update(group_params)
      redirect_to @group
    else
      @groups = Group.all.order( :category, :name )
      render 'show'
    end
  end

  private

  def group_params
    params.require(:group).permit( :name, :category, :comments)
  end
end
