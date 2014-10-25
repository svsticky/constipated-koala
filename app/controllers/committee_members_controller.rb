class CommitteeMembersController < ApplicationController
  respond_to :json

  def find
    @members = Member.select(:id, :first_name, :infix, :last_name, :student_id).search(params[:search])
    respond_with @members
  end

  def create
    @committee = Committee.find(params[:committee])
    @committeeMember = CommitteeMember.new( :member => Member.find(params[:member]), :committee => @committee )

    if @committeeMember.save
      respond_with @committeeMember, :location => committees_url
    else
      respond_with @committeeMember.errors.full_messages
    end      
  end

  def update
    @committeeMember = CommitteeMember.find(params[:id])

    @committeeMember.update_attributes(:function => params[:functionName])
    if @committeeMember.save
      render :status => :ok, :json => @committeeMember
    else
      respond_with @committeeMember.errors.full_messages
    end
  end

  def destroy
    respond_with CommitteeMember.destroy(params[:id])
  end
end