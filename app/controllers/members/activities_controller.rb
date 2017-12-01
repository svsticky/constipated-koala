# The activities controller handles all actions related to enrollment for
# activities by users.
# The various methods in this controller directly manipulate Participants, a
# many-to-many association on Members, and changes made will be visible in the
# admin view. Note that the :id parameters here correspond to Activity ids, and
# not Participant ids, as this makes linking to the enrollment page for a
# single activity possible.
class Members::ActivitiesController < MembersController
  # [GET] /activities
  # Renders the overview of all future activities that are enrollable.
  def index
    @member = Member.find(current_user.credentials_id)
    @activities = Activity
      .where('(end_date IS NULL AND start_date >= ?) OR end_date >= ?',
             Date.today, Date.today)
      .where(is_viewable: true)
      .order(:start_date)
    @activities = @activities.reject { |a| a.ended? }
  end

  # [GET] /activities/:id
  # Renders the detail view of one activity, containing information about the
  # activity, the list of enrolled people and reservists, and the notes entry
  # field.
  def show
    @activity = Activity.find(params[:id])
    @member = Member.find(current_user.credentials_id)

    # Don't allow activities for old activities
    if @activity.ended?
      render :status => :gone, :plain => I18n.t(:activity_ended, scope: 'activerecord.errors.models.activity')
      return
    end

    @enrollment = Participant.find_by(
      member_id: current_user.credentials_id,
      activity_id: @activity.id
    )

    @attendees = @activity.ordered_attendees
    @reservists = @activity.ordered_reservists
  end
end
