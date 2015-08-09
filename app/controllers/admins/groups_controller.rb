class Admins::GroupsController < ApplicationController

  def index
    @groups = Group.all
    @group = Group.new
  end

  def show
    @group = Group.find(params[:id])
  end

  def create
    @group = Group.new(committee_post_params)

    if @group.save
      redirect_to @group
    else
      @groups = Group.all
      render 'index'
    end
  end

  def update
    @group = Group.find(params[:id])

    if @group.update(committee_post_params)
      redirect_to @group
    else
      render 'edit'
      return
    end
  end

  def createMember
    @member = GroupMember.new( :member => Member.find(params[:searchId]), :group => Group.find(params[:id]) )

    if @member.save
      respond_with @member, :location => groups_url
    else
      respond_with @member.errors.full_messages
    end
  end

  def destroyMember
    respond_with GroupMember.destroy(params[:id])
  end

  private
  def committee_post_params
    params.require(:committee).permit( :name,
                                       :comments)
  end
end
