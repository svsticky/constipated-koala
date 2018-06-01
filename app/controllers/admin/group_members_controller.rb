#:nodoc:
class Admin::GroupMembersController < ApplicationController
  respond_to :json, only: [:create, :update, :destroy]

  def create
    logger.debug params.inspect

    @member = GroupMember.new(:member => Member.find_by_id(params[:member]), :group => Group.find_by_id(params[:group_id]), :year => params[:year])

    if @member.save
      impressionist @member
      respond_with @member, :location => groups_url
    else
      respond_with @member.errors.full_messages
    end
  end

  def update
    @member = GroupMember.find_by_id(params[:id])

    if @member.update(:position => params[:position])
      impressionist @member
      respond_with @member, :location => groups_url
    else
      respond_with @member.errors.full_messages
    end
  end

  def destroy
    respond_with GroupMember.destroy(params[:id])
  end
end
