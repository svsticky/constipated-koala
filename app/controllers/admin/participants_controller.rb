class Admin::ParticipantsController < ApplicationController
  respond_to :json

  def create
    @activity = Activity.find_by_id params[:activity_id]
    @participant = Participant.new( :member => Member.find(params[:member]), :activity => @activity)

    if @participant.save
      impressionist(@participant)
      @response = @participant.attributes #TODO refactor, very old code
      @response[ 'price' ] = @activity.price
      @response[ 'email' ] = @participant.member.email
      @response[ 'name'  ] = @participant.member.name

      render :status => :created, :json => @response.to_json
    end
  end

  def update
    participant = Participant.find(params[:id])

    if !params[:paid].nil?
      message = params[:paid].to_b ? 'paid' : 'unpaid'
      participant.update_attribute(:paid, params[:paid]) if !participant.currency.nil?
    elsif !params[:price].nil?
      if !params[:price].is_number?
        raise 'not a number'
      end

      message = 'price'
      participant.update_attributes(:price => params[:price])
    end

    if participant.save
      impressionist(participant, message)
      render :status => :ok, :json => participant
      return
    else
      respond_with participant.errors.full_messages
    end
  end

  def destroy
    ghost_participant = Participant.destroy(params[:id])

    if ghost_participant.activity.instance_variable_get(:@magic_enrolled_reservists)
      @response = []

      ghost_participant.activity.instance_variable_get(:@magic_enrolled_reservists).each do |peep|
        item = peep.attributes
        item['price'] = peep.activity.price
        item['email'] = peep.member.email
        item['name']  = peep.member.name

        @response << item
      end

      render :status => :ok, :json => @response.to_json
    else
      head :no_content
    end
  end

  def mail
    render :json => Mailings::Participants.inform( Activity.find_by_id!(params[:activity_id]), params[:recipients].map{ | id, item | item['email'] }, current_user.sender, params[:subject], params[:html] ).deliver_later
  end
end
