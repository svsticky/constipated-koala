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
          
    logger.debug @participant.inspect
          
    if !params[:paid].nil?
      if !@participant.currency.nil?
        @participant.update_attribute(:paid, params[:paid])
      end
    elsif !params[:price].nil?
      if !params[:price].numeric?
        raise 'not a number'
      end
    
      if BigDecimal.new(params[:price]) == @participant.activity.price
        @participant.update_attribute(:price, NIL)
      else
        @participant.update_attribute(:price, params[:price])
      end
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

class String
  def numeric?
    return true if self =~ /^\d+$/
    true if Float(self) rescue false
  end
end  