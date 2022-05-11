#:nodoc:
class Admin::GroupMembersController < ApplicationController
  def create
    @member = GroupMember.new(member: Member.find_by(id: params[:member]), group: Group.find_by(id: params[:group_id]), year: params[:year])

    head(:bad_request) unless @member.save

    impressionist(@member)
    render(status: :created)
  end

  def update
    @member = GroupMember.find_by(id: params[:id])

    head(:bad_request) unless @member.update(position: params[:position])

    impressionist(@member)
    head(:no_content)
  end

  def destroy
    head(:no_content) if GroupMember.destroy(params[:id])
  end
end
