# The activities controller handles all actions related to enrollment for
# activities by users.
# The various methods in this controller directly manipulate Participants, a
# many-to-many association on Members, and changes made will be visible in the
# admin view. Note that the :id parameters here correspond to Activity ids, and
# not Participant ids, as this makes linking to the enrollment page for a
# single activity possible.
#:nodoc:
class Members::ActivitiesController < ApplicationController
  skip_before_action :authenticate_admin!

  layout 'members'

  # [GET] /activities
  # Renders the overview of all future activities that are enrollable.
  def index
    @activities = Activity.upcoming.includes(:participants)
  end

  # [GET] /activities/:id
  # Renders the detail view of one activity, containing information about the
  # activity, the list of enrolled people and reservists, and the notes entry
  # field.
  def show
    @activity = Activity.find(params[:id])

    # Don't allow activities for old activities #TODO
    # render :unavailable, :status => :gone if @activity.ended? || !@activity.is_viewable?

    @participant = Participant.find_by(
      member_id: Member.find(current_user.credentials_id).id,
      activity_id: @activity.id
    ) || Participant.new
  end
end
