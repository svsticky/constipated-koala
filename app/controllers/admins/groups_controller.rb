class Admins::GroupsController < ApplicationController
  impressionist :actions => [ :create, :update ]
  respond_to :json, only: [ :create_member, :update_member, :destroy_member, :find_position ]

  def index
    @groups = Group.all.order( :category, :name )
    @new = Group.new if params[:id].blank?
    @group = Group.find(params[:id]) unless params[:id].blank?
  end

  def create
    @new = Group.new(group_params)

    if @new.save
      redirect_to @new
    else
      @groups = Group.all.order( :category, :name )
      render 'index'
    end
  end

  def update
    @group = Group.find(params[:id])

    if @group.update(group_params)
      redirect_to @group
    else
      render 'edit'
      return
    end
  end

  def create_member
    @member = GroupMember.new( :member => Member.find(params[:member]), :group => Group.find(params[:id]), :year => params[:year] )

    if @member.save
      impressionist @member
      respond_with @member, :location => groups_url
    else
      respond_with @member.errors.full_messages
    end
  end

  def update_member
    @member = GroupMember.find(params[:member])

    if @member.update( :position => params[:position] )
      impressionist @member
      respond_with @member, :location => groups_url
    else
      respond_with @member.errors.full_messages
    end
  end

  def destroy_member
    respond_with GroupMember.destroy(params[:member])
  end

  private
  def group_params
    params.require(:group).permit( :name, :category, :comments)
  end
end
