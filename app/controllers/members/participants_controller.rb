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
    # Don't allow signups for old activities
    if @activity.ended?
      render status: :gone, json: {
        message: I18n.t(:activity_ended, scope: @activity_errors_scope)
      }
      return
    end

    @member = Member.find(current_user.credentials_id)
    @notes = params[:par_notes]
    reservist = false

    # Deny if already enrolled
    if Participant.exists?(activity: @activity, member: @member)
      render status: :conflict, json: {
        message: I18n.t(:already_enrolled, scope: @activity_errors_scope)
      }
      return
    # Deny members that don't have an active study, unless the member is a
    # pardon, merit or honary member or donator.
    elsif !@member.may_enroll?
      render status: :failed_dependency, json: {
        message: I18n.t(:participant_no_student, scope: @activity_errors_scope),
        participant_limit: @activity.participant_limit,
        participant_count: @activity.participants.count
      }
      return
    # Deny suspended members
    elsif Tag.exists?(member: @member, name: Tag.names[:suspended])
      render status: :failed_dependency, json: {
        message: I18n.t(:participant_suspended, scope: @activity_errors_scope),
        participant_limit: @activity.participant_limit,
        participant_count: @activity.participants.count
      }
      return
    # Deny if activity not enrollable
    elsif !@activity.open?
      render status: :locked, json: {
        message: I18n.t(:not_enrollable, scope: @activity_errors_scope),
        participant_limit: @activity.participant_limit,
        participant_count: @activity.participants.count
      }
      return
    # Deny minors from alcoholic activities
    elsif participant_alcohol_check?
      render status: :unavailable_for_legal_reasons, json: {
        message: I18n.t(:participant_underage, scope: @activity_errors_scope, activity: @activity.name),
        participant_limit: @activity.participant_limit,
        participant_count: @activity.participants.count
      }
      return
    # Check if notes are present and deny if absent and required.
    elsif participant_notes_check?
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
    elsif participant_limit_check?
      reservist = true
      reason_for_spare_message = I18n.t(:participant_limit_reached,
                                        scope: @activity_errors_scope,
                                        activity: @activity.name)
    elsif !participant_filter_check?
      reservist = true
      if !participant_freshman_check?
        reason = :participant_no_freshman
      elsif !participant_sophomore_check?
        reason = :participant_no_sophomore
      elsif !participant_senior_check?
        reason = :participant_no_seniors
      elsif !participant_master_check?
        reason = :participant_no_masters
      end
      reason_for_spare_message = I18n.t(reason,
                                        scope: @activity_errors_scope,
                                        activity: @activity.name)
    end

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

      render status: :ok, json: {
        message: I18n.t(:enrolled, scope:
          @activity_errors_scope, activity:
                          @activity.name),
        participant_limit: @activity.participant_limit,
        participant_count: @activity.participants.count
      }
    end
  end

  # Helper functions to decrease the complexity of create
  def participant_filter_check?
    participant_freshman_check? || participant_sophomore_check? || participant_senior_check? || participant_master_check?
  end

  def participant_freshman_check?
    @activity.is_freshmans? && @member.freshman?
  end

  def participant_sophomore_check?
    @activity.is_sophomores? && @member.sophomore?
  end

  def participant_senior_check?
    @activity.is_seniors? && @member.senior?
  end

  def participant_master_check?
    @activity.is_masters? && @member.master?
  end

  def participant_notes_check?
    @activity.notes.present? && @activity.notes_mandatory && params[:par_notes].blank?
  end

  def participant_limit_check?
    !@activity.participant_limit.nil? && @activity.attendees.count >= @activity.participant_limit
  end

  def participant_alcohol_check?
    @activity.is_alcoholic? && @member.underage?
  end

  # [PATCH] /activities/:id/participants
  # Used for updating member notes
  def update
    @member = Member.find(current_user.credentials_id)

    @enrollment = Participant.find_by(
      member_id: @member.id,
      activity_id: @activity.id
    )

    if @activity.notes.blank? || params[:par_notes].present?
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

    @member = Member.find(current_user.credentials_id)

    # Raises RecordNotFound if not enrolled
    @enrollment = Participant.find_by!(
      member_id: @member.id,
      activity_id: @activity.id
    )

    # A reservist can unroll after the deadline, a participant cannot
    if not_enrollable || (deadline_passed && !@enrollment.reservist)
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

    activity = @enrollment.activity
    @enrollment.destroy!
    activity.enroll_reservists!

    render status: :ok, json: {
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
      render status: :gone,
             plain: I18n.t(
               :activity_ended,
               scope: 'activerecord.errors.models.activity'
             )
    end
  end
end
