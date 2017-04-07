# The enrollments controller handles all actions related to enrollment for
# activities by users.
# The various methods in this controller directly manipulate Participants, a
# many-to-many association on Members, and changes made will be visible in the
# admin view. Note that the :id parameters here correspond to Activity ids, and
# not Participant ids, as this makes linking to the enrollment page for a
# single activity possible.
class Users::EnrollmentsController < ApplicationController
  skip_before_action :authenticate_admin!, only: [ :index, :show, :create, :update, :delete ]

  # [GET] /enrollments
  # Renders the overview of all future activities that are enrollable.
  def index
    @activities = Activity.where(
      '(end_date IS NULL AND start_date >= ?) OR end_date >= ?',
        Date.today, Date.today
      ).where('is_viewable = TRUE').order(:start_date)
    @current_member = Member.find(current_user.credentials_id)
  end

  # [GET] /enrollments/:id
  # Renders the detail view of one activity, containing information about the
  # activity, the list of enrolled people and reservists, and the notes entry
  # field.
  def show
    @activity = Activity.find(params[:id])

    # Don't allow enrollments for old activities
    if @activity.end <= Time.now
      render :status => :gone, :plain => I18n.t(:activity_ended, scope: 'activerecord.errors.models.activity')
      return
    end

    @current_member = Member.find(current_user.credentials_id)
    @enrollment = Participant.find_by(
        member_id: current_user.credentials_id,
        activity_id: @activity.id)
  end

  # [POST] /enrollments/:id
  # Create a new Participant if that's allowed.
  def create
    @activity = Activity.find(params[:id])

    @member = Member.find(current_user.credentials_id)

    # Don't allow enrollments for old activities
    if @activity.end <= Time.now
      render :status => :gone, :json => {
        message: I18n.t(:activity_ended, scope:
          'activerecord.errors.models.activity')
      }
      return
    end

    # Deny suspended members
    if Tag.exists?(member: @member, name: 5)
      render :status => :failed_dependency, :json => {
          message: I18n.t(:participant_suspended, scope:
            'activerecord.errors.models.activity'),
          participant_limit: @activity.participant_limit,
          participant_count: @activity.participants.count
      }
      return
    end

    # Deny if activity not enrollable
    if !@activity.is_enrollable?
      render :status => :locked, :json => {
        message: I18n.t(:not_enrollable, scope: 'activerecord.errors.models.activity'),
        participant_limit: @activity.participant_limit,
        participant_count: @activity.participants.count
      }
      return
    end

    # Deny minors from alcoholic activities
    if @activity.is_alcoholic? && @member.is_underage?
      render :status => 451, :json => { # Unavailable for legal reasons
        message: I18n.t(:participant_underage, scope: 'activerecord.errors.models.activity', activity: @activity.name),
        participant_limit: @activity.participant_limit,
        participant_count: @activity.participants.count
      }
      return
    end

    # Check if notes are present and deny if absent and required.
    if(@activity.notes.blank? || !params[:par_notes].blank?)
      @notes = params[:par_notes]

      # Reservist if no spots left
      if !@activity.participant_limit.nil? &&
          @activity.participants.count >= @activity.participant_limit

        @new_enrollment = Participant.new(
          member_id: @member.id,
          activity_id: @activity.id,
          price: @activity.price,
          notes: @notes,
          reservist: true
        )
        @new_enrollment.save!

        render :status => :accepted, :json => {
          message: I18n.t(:participant_limit_reached, scope:
                          'activerecord.errors.models.activity', activity:
                          @activity.name),
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

        render :status => 200, :json => {
            message: I18n.t(:enrolled, scope:
                            'activerecord.errors.models.activity', activity:
                            @activity.name),
            participant_limit: @activity.participant_limit,
            participant_count: @activity.participants.count
        }
      end
    else
      # Notify that notes are required
      render :status => :precondition_failed, :json => {
        message: I18n.t(
          :participant_notes_not_filled,
          scope: 'activerecord.errors.models.activity',
          activity: @activity.name
        ),
        participant_limit: @activity.participant_limit,
        participant_count: @activity.participants.count
      }
      return
    end
  end

  # [PATCH] /enrollments/:id
  # Used for updating member notes
  def update
    @activity = Activity.find(params[:id])

    @enrollment = Participant.find_by(
        member_id: current_user.credentials_id,
        activity_id: @activity.id)

    if(@activity.notes.blank? || !params[:par_notes].blank?)
      @enrollment.update(notes: params[:par_notes])
      @enrollment.save
      render :status => :accepted, :json => {
        message: I18n.t(
          :participant_notes_updated,
          scope: 'activerecord.errors.models.activity',
          activity: @activity.name
        ),
        participant_limit: @activity.participant_limit,
        participant_count: @activity.participants.count
      }
    else
      render :status => :precondition_failed, :json => {
        message: I18n.t(
          :participant_notes_not_filled,
          scope: 'activerecord.errors.models.activity',
          activity: @activity.name
        ),
        participant_limit: @activity.participant_limit,
        participant_count: @activity.participants.count
      }
    end
  end

  # [DELETE] /enrollments/:id
  # Performs checks to see whether or not the member is enrolled in the given
  # activity, and then cancels the member's enrollment. (Deletes the
  # Participant)
  def delete
    @activity = Activity.find(params[:id])

    # Unenrollment is denied if the activity is not or no longer enrollable by
    # users, or if the unenroll date has passed.
    if !@activity.is_enrollable? or
        (@activity.unenroll_date and @activity.unenroll_date < DateTime.now)
      render :status => :locked, :json => {
        message: I18n.t(
          :not_unenrollable,
          scope: 'activerecord.errors.models.activity',
          activity: @activity.name
        ),
        participant_limit: @activity.participant_limit,
        participant_count: @activity.participants.count
      }
      return
    end

    # Raises RecordNotFound if not enrolled
    @enrollment = Participant.find_by!(
        member_id: current_user.credentials_id,
        activity_id: @activity.id)

    @enrollment.destroy!

    render :status => 200, :json => {
        message: I18n.t(
          :not_enrolled,
          scope: 'activerecord.errors.models.activity',
          activity: @activity.name
        ),
        participant_limit: @activity.participant_limit,
        participant_count: @activity.participants.count
    }
  end
end
