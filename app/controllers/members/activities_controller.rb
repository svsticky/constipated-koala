# The activities controller handles all actions related to enrollment for
# activities by users.
# The various methods in this controller directly manipulate Participants, a
# many-to-many association on Members, and changes made will be visible in the
# admin view. Note that the :id parameters here correspond to Activity ids, and
# not Participant ids, as this makes linking to the enrollment page for a
# single activity possible.
#:nodoc:
class Members::ActivitiesController < MembersController
  before_action :set_activity!, except: [:index]

  # [GET] /activities
  # Renders the overview of all future activities that are enrollable.
  def index
    @activities = Activity
                  .where('(end_date IS NULL AND start_date >= ?) OR end_date >= ?',
                         Date.today, Date.today)
                  .where(is_viewable: true)
                  .order(:start_date, :start_time)
    @activities = @activities.reject(&:ended?)
  end

  # [GET] /activities/:id
  # Renders the detail view of one activity, containing information about the
  # activity, the list of enrolled people and reservists, and the notes entry
  # field.
  def show
    @member = Member.find(current_user.credentials_id)
    
    @enrollment = Participant.find_by(
      member_id: @member.id,
      activity_id: @activity.id
    )

    @attendees = @activity.ordered_attendees
    @reservists = @activity.ordered_reservists
  end
end
