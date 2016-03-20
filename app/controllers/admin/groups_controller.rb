class Admin::GroupsController < ApplicationController
  impressionist :actions => [ :create, :update ]

  def index
    @groups = Group.all.order( :category, :name )
    @new = Group.new
  end

  def show
    @groups = Group.all.order( :category, :name )
    @group = Group.find_by_id params[:id]
  end

  def create
    @new = Group.new group_params

    if @new.save
      redirect_to @new
    else
      @groups = Group.all.order( :category, :name )
      render 'index'
    end
  end

  def update
    @group = Group.find_by_id params[:id]

    if @group.update(group_params)
      redirect_to @group
    else
      render 'edit'
      return
    end
  end

  private
  def group_params
    params.require(:group).permit( :name, :category, :comments)
  end
end
