class ParticipantsController < ApplicationController  
  respond_to :json
  
  def list
    if params[:activity].blank?
      raise 'no activity'
    end

    @participants = Participant.where( :activity => params[:activity])
  
    if params[:recipients] == 'all'
      respond_with @participants.joins(:member).order('members.first_name', 'members.last_name').select(:id, :first_name, :infix, :last_name, :email)
    elsif params[:recipients] == 'debtors'
      respond_with @participants.where( :paid => false ).joins(:member).order('members.first_name', 'members.last_name').select(:id, :first_name, :infix, :last_name, :email)
    else
      raise ActiveRecord::RecordNotFound
    end
  end
  
  def find
    # do some extra filtering
    @members = Member.select(:id, :first_name, :infix, :last_name, :student_id).search(params[:search])
    respond_with @members
  end
  
  def create
    @activity = Activity.find(params[:activity])
    @participant = Participant.new( :member => Member.find(params[:member]), :activity => @activity)
    
    if @activity.price == 0
      @participant.update_attribute(:paid, true)
    end
    
    if @participant.save
      @response = @participant.attributes
      @response[ 'price' ] = @activity.price
      @response[ 'email' ] = @participant.member.email
      respond_with @response, :location => activities_url
    else
      respond_with @participant.errors.full_messages
    end
  end
  
  def update
    @participant = Participant.find(params[:id])
          
    if !params[:paid].nil?
      if !@participant.currency.nil?
        @participant.update_attribute(:paid, params[:paid])
      end
    elsif !params[:price].nil?
      if !params[:price].is_number?
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
      return
    else
      respond_with @participant.errors.full_messages
    end
  end
  
  def destroy
    respond_with Participant.destroy(params[:id])
  end
  
  def mail
    @activity = Activity.find(params[:id])
    render :json => Mailgun.participant_information(params[:recipients], @activity, current_user.credentials.sender, params[:subject], nil, params[:text]).deliver_later
  end
end