class ParticipantsController < ApplicationController  
  respond_to :json
  
  def list
    if params[:activity].blank?
      raise 'no activity'
    end

    @participants = Participant.where( :activity => params[:activity])
  
    logger.debug(@participants)
  
    if params[:recipients] == 'all'
      respond_with @participants.joins(:member).select(:id, :first_name, :infix, :last_name, :email)
    elsif params[:recipients] == 'debtors'
      respond_with @participants.where( :paid => false ).joins(:member).select(:id, :first_name, :infix, :last_name, :email)
    else
      raise ActiveRecord::RecordNotFound
    end
  end
  
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
          
    logger.debug @participant.inspect
          
    if !params[:paid].nil?
      if !@participant.currency.nil?
        @participant.update_attribute(:paid, params[:paid])
      end
    elsif !params[:price].nil?
      if !params[:price].numeric?
        raise 'not a number'
      end
      
      if BigDecimal.new(params[:price]) == 0
        @participant.update_attributes(:price => 0, :paid => true)
      elsif BigDecimal.new(params[:price]) == @participant.activity.price
        @participant.update_attributes(:price => NIL, :paid => false)
      else
        @participant.update_attributes(:price => params[:price], :paid => false)
      end
    end
    
    if @participant.save
      render :status => :ok, :json => @participant
    else
      respond_with @participant.errors.full_messages
    end
  end
  
  def destroy
    respond_with Participant.destroy(params[:id])
  end
end

class String
  def numeric?
    return true if self =~ /^\d+$/
    true if Float(self) rescue false
  end
end  