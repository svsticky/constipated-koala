#:nodoc:
class Admin::ParticipantsController < ApplicationController
  def create
    @participant = Participant.new(
      member: Member.find_by_id(params[:member]),
      activity: Activity.find_by_id(params[:activity_id])
    )

    impressionist(@participant) if @participant.save
  end

  def update
    @participant = Participant.find(params[:id])
    puts @participant

    if params[:reservist].present?
      message = params[:reservist].to_b ? 'reservist' : 'participant'
      @participant.update(reservist: params[:reservist])

      # notify participant of enrollment
      Mailings::Participants.enrolled(@participant).deliver_later
    end

    if params[:paid].present?
      message = params[:paid].to_b ? 'paid' : 'unpaid'
      @participant.update(paid: params[:paid]) unless @participant.currency.nil?
    elsif params[:price].present?
      raise 'not a number' unless params[:price].is_number?

      message = 'price'
      @participant.update(price: params[:price])
    elsif params[:sac_points].present?
      raise 'negative sac points' unless params[:sac_points].to_i >= 0
      @participant.update(sac_points: params[:sac_points])
    end

    if @participant.save
      impressionist(@participant, message)
      render status: :ok
    end
  end

  def destroy
    ghost = Participant.destroy params[:id]

    @activity = ghost.activity
    @reservists = @activity.enroll_reservists!

    render status: :ok
  end

  def mail
    # TODO: it looks like the http post response is returned to the user, if that is the case it should be changed to `head :ok`
    @activity = Activity.find(params[:activity_id])
    render json: Mailings::Participants.inform(@activity, params[:recipients].permit!.to_h.map { |_, item| item['email'] }, current_user.sender, params[:subject], params[:html]).deliver_later
    impressionist(@activity, "mail")
  end
end
