class ParticipantsController < ApplicationController  
  respond_to :json
  
  def find
    @members = Member.search(params[:search]).select(:id, :first_name, :infix, :last_name)
    respond_with @members
  end
  
  def create
    @participant = Participant.new( :member => Member.find(params[:member]), :activity => Activity.find(params[:activity]))
    
    if @participant.save
      respond_with @participant, :location => activities_url
    else
      respond_with @participant.errors.full_messages
    end
  end
  
  def update
    @participant = Participant.find(params[:id])
          
    if !params[:paid].nil?
      @participant.update_attribute(:paid, params[:paid])
    elsif !params[:price].nil?
      @participant.update_attribute(:price, params[:price])
    end
    
    if @participant.save
      respond_with @participant
    else
      respond_with @participant.errors.full_messages
    end
  end
  
  def destroy
    respond_with Participant.destroy(params[:id])
  end
end
