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
  before_action :set_activity!

  layout 'members'

  def initialize
    @activity_errors_scope = 'activerecord.errors.models.activity'
  end

  # [POST] /activities/:id/participants
  # Create a new Participant if that's allowed.
  def create
    # Don't allow activities for old activities
    if @activity.ended?
      render status: :gone, json: {
        message: I18n.t(:activity_ended, scope: @activity_errors_scope)
      }
      return
    end

    @member = Member.find(current_user.credentials_id)

    # Deny if already enrolled
    if Participant.exists?(activity: @activity, member: @member)
      render status: :conflict, json: {
        message: I18n.t(:already_enrolled, scope: @activity_errors_scope)
      }
      return
    end

    # Deny members that don't study, except if they tagged
    unless @member.may_enroll?
      render status: :failed_dependency, json: {
        message: I18n.t(:participant_no_student, scope: @activity_errors_scope),
        participant_limit: @activity.participant_limit,
        participant_count: @activity.participants.count
      }
      return
    end

    # Deny suspended members
    if Tag.exists?(member: @member, name: Tag.names[:suspended])
      render status: :failed_dependency, json: {
        message: I18n.t(:participant_suspended, scope: @activity_errors_scope),
        participant_limit: @activity.participant_limit,
        participant_count: @activity.participants.count
      }
      return
    end

    # Deny if activity not enrollable
    unless @activity.open?
      render status: :locked, json: {
        message: I18n.t(:not_enrollable, scope: @activity_errors_scope),
        participant_limit: @activity.participant_limit,
        participant_count: @activity.participants.count
      }
      return
    end

    # Deny minors from alcoholic activities
    if @activity.is_alcoholic? && @member.underage?
      render status: 451, json: { # Unavailable for legal reasons
        message: I18n.t(:participant_underage, scope: @activity_errors_scope, activity: @activity.name),
        participant_limit: @activity.participant_limit,
        participant_count: @activity.participants.count
      }
      return
    end

    # Check if notes are present and deny if absent and required.
    if @activity.notes.present? && @activity.notes_mandatory && params[:par_notes].blank?
      # Notify that notes are required
      render status: :precondition_failed, json: {
        message: I18n.t(
          :participant_notes_not_filled,
          scope: @activity_errors_scope,
          activity: @activity.name
        ),
        participant_limit: @activity.participant_limit,
        participant_count: @activity.participants.count
      }
      return
    end

    @notes = params[:par_notes]
    reservist = false
    if !@activity.participant_limit.nil? && @activity.attendees.count >= @activity.participant_limit
      reservist = true
      reason_for_spare_message = I18n.t(:participant_limit_reached,
                                        scope: @activity_errors_scope,
                                        activity: @activity.name)
    elsif !@member.masters? && @activity.is_masters?
      reservist = true
      reason_for_spare_message = I18n.t(:participant_no_masters,
                                        scope: @activity_errors_scope,
                                        activity: @activity.name)
    elsif !@member.freshman? && @activity.is_freshmans?
      reservist = true
      reason_for_spare_message = I18n.t(:participant_no_freshman,
                                        scope: @activity_errors_scope,
                                        activity: @activity.name)
    end

    # Reservist if no spots left or masters activity or freshmans activity
    if reservist
      @new_enrollment = Participant.new(
        member_id: @member.id,
        activity_id: @activity.id,
        price: @activity.price,
        notes: @notes,
        reservist: true
      )
      @new_enrollment.save!

      spare_list_message = I18n.t(:backup_enrolled,
                                  scope: @activity_errors_scope,
                                  activity: @activity.name)

      render status: :accepted, json: {
        message: "#{ reason_for_spare_message } #{ spare_list_message }",
        participant_limit: @activity.participant_limit,
        participant_count: @activity.participants.count
      }
      return
    else
      @new_enrollment = Participant.new(
        member_id: @member.id,
        activity_id: @activity.id,
        price: @activity.price,
        notes: @notes
      )

      @new_enrollment.save!

      render status: 200, json: {
        message: I18n.t(:enrolled, scope:
          @activity_errors_scope, activity:
                          @activity.name),
        participant_limit: @activity.participant_limit,
        participant_count: @activity.participants.count
      }
    end
  end

  # [PATCH] /activities/:id/participants
  # Used for updating member notes
  def update
    @member = Member.find(current_user.credentials_id)

    @enrollment = Participant.find_by(
      member_id: @member.id,
      activity_id: @activity.id
    )

    if @activity.notes.blank? || !params[:par_notes].blank?
      @enrollment.update(notes: params[:par_notes])
      @enrollment.save
      render status: :accepted, json: {
        message: I18n.t(
          :participant_notes_updated,
          scope: @activity_errors_scope,
          activity: @activity.name
        ),
        participant_limit: @activity.participant_limit,
        participant_count: @activity.participants.count
      }
    else
      render status: :precondition_failed, json: {
        message: I18n.t(
          :participant_notes_not_filled,
          scope: @activity_errors_scope,
          activity: @activity.name
        ),
        participant_limit: @activity.participant_limit,
        participant_count: @activity.participants.count
      }
    end
  end

  # [DELETE] /activities/:id/participants
  # Performs checks to see whether or not the member is enrolled in the given
  # activity, and then cancels the member's enrollment. (Deletes the
  # Participant)
  def destroy
    # Unenrollment is denied if the activity is not or no longer enrollable by
    # users, or if the unenroll date has passed.
    not_enrollable = !@activity.open?
    deadline_passed = @activity.unenroll_date&.end_of_day &&
                      @activity.unenroll_date.end_of_day < Time.now

    if not_enrollable || deadline_passed
      message = I18n.t(:not_unenrollable, scope: @activity_errors_scope)

      if not_enrollable
        message = I18n.t(:not_enrollable, scope: @activity_errors_scope)
      elsif deadline_passed
        message = I18n.t(:unenroll_date_passed, scope: @activity_errors_scope)
      end

      render status: :locked, json: {
        message: message,
        participant_limit: @activity.participant_limit,
        participant_count: @activity.participants.count
      }
      return
    end

    @member = Member.find(current_user.credentials_id)

    # Raises RecordNotFound if not enrolled
    @enrollment = Participant.find_by!(
      member_id: @member.id,
      activity_id: @activity.id
    )
    activity = @enrollment.activity
    @enrollment.destroy!
    activity.enroll_reservists!

    render status: 200, json: {
      message: I18n.t(
        :unenrolled,
        scope: @activity_errors_scope,
        activity: @activity.name
      ),
      participant_limit: @activity.participant_limit,
      participant_count: @activity.participants.count
    }
  end

  private

  def set_activity!
    activity_id = params[:activity_id] || params[:id]
    @activity = Activity.find(activity_id)

    # Don't allow activities for old activities
    if @activity.ended? || !@activity.is_viewable? # rubocop:disable Style/GuardClause
      render :status => :gone,
             :plain => I18n.t(
               :activity_ended,
               scope: 'activerecord.errors.models.activity'
             )
    end
  end
end
