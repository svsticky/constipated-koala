# The activities controller handles all actions related to enrollment for
# activities by users.
# The various methods in this controller directly manipulate Participants, a
# many-to-many association on Members, and changes made will be visible in the
# admin view. Note that the :id parameters here correspond to Activity ids, and
# not Participant ids, as this makes linking to the enrollment page for a
# single activity possible.
#:nodoc:
class Members::ParticipantsController < ApplicationController
  skip_before_action :authenticate_admin!

  layout 'members'

  # [POST] /activities/:id/participants
  # Create a new Participant if that's allowed.
  def create
    @activity = Activity.find_by_id params[:activity_id]
    @participant = Participant.new(
       member: Member.find(current_user.credentials_id),
       activity: @activity
    )

    @participant.notes = participant_params[:notes] if @activity.notes_mandatory
    flash[:notices] = @participant.reservist!

    if @participant.save
      redirect_to @participant.activity
    else
      render 'members/activities/show'
    end
  end

  # [PATCH] /activities/:id/participants
  # Used for updating member notes
  def update
    @activity = Activity.find_by_id params[:activity_id]
    @participant = Participant.find_by(
       member_id: Member.find(current_user.credentials_id).id,
       activity_id: @activity.id
    )

    @participant.errors.add(:notes, I18n.t('activerecord.errors.participant.blank')) if @activity.notes_mandatory && participant_params[:notes].blank?

    if @participant.errors.blank? && @participant.update(participant_params)
      redirect_to @activity
    else
      render 'members/activities/show'
    end
  end

  # [DELETE] /activities/:id/participants
  # Performs checks to see whether or not the member is enrolled in the given
  # activity, and then cancels the member's enrollment. (Deletes the
  # Participant)
  def destroy
    @activity = Activity.find_by_id params[:activity_id]

    if @activity.unenroll?
      flash[:error] = I18n.t(:unenroll_date_passed, scope: 'activerecord.errors.models.activity')
      redirect_to @activity
      return
    end

    @participant = Participant.find_by!(
      member_id: Member.find(current_user.credentials_id).id,
      activity_id: @activity.id
    )

    @activity.enroll_reservists! if @participant.destroy
    redirect_to @activity
  end

  private

  def participant_params
    params.require(:participant).permit(:notes)
  end
end
