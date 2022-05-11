#:nodoc:
class Admin::GroupsController < ApplicationController
  # replaced with calls in each of the methods
  # impressionist :actions => [ :create, :update ]

  def index
    @groups = Group.all.order(:category, :name)
    @group = Group.new
  end

  def show
    @groups = Group.all.order(:category, :name)
    @group = Group.find_by(id: params[:id])
  end

  def create
    @group = Group.new(group_params)

    if @group.save
      impressionist(@group)
      redirect_to(@group)
    else
      @groups = Group.all.order(:category, :name)
      render('show')
    end
  end

  def update
    @group = Group.find_by(id: params[:id])

    if @group.update(group_params)
      impressionist(@group)
      redirect_to(@group)
    else
      @groups = Group.all.order(:category, :name)
      render('show')
    end
  end

  def destroy
    @group = Group.find(params[:id])

    if @group.category == "board"
      redirect_to(group_path)
    else
      @group.destroy
      redirect_to(groups_path)
    end
  end

  private

  def group_params
    params.require(:group).permit(:name, :category, :comments, :ledgernr, :cost_location)
  end
end
