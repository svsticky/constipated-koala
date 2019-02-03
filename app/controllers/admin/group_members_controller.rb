#:nodoc:
class Admin::GroupMembersController < ApplicationController

  def create
    @member = GroupMember.new(:member => Member.find_by_id(params[:member]), :group => Group.find_by_id(params[:group_id]), :year => params[:year])

    if @member.save
      impressionist @member
      render :status => :created
    end
  end

  def update
    @member = GroupMember.find_by_id(params[:id])

    if @member.update(:position => params[:position])
      impressionist @member
      head :no_content
    end
  end

  def destroy
    if GroupMember.destroy(params[:id])
      head :no_content
    end
  end
end
