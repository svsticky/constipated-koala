require 'icalendar_helper'

class Api::CalendarsController < ActionController::Base
  # supply the personalised iCal feed from the user
  def show
    @member = Member.find_by(calendar_id: params[:calendar_id])
		# member variable will be accessible in other methods as well now

    if not @member # No member with the specified hash was found
      render json: { error: "Unkown hash" }, status: :not_found
      return
    end
    
    respond_to do |format|
      format.ics {
        send_data create_personal_calendar,
        type: 'text/calendar',
        disposition: 'attachment',
        filename: "#{@member.first_name}_activities.ics"
      }
    end
  end

  def index
    if current_user.nil?
      render json: { error: "Not logged in" }, status: :forbidden
      return
    end # TODO heb je overal dit soort error handling?

    @member = Member.find(current_user.credentials_id)
    render plain: "https://koala.svsticky.nl/api/calendar/pull/#{@member.calendar_id}" # TODO can this less hard-coded?
  end

  # Not exposed to API directly, but through #show
  def create_personal_calendar
    @locale = I18n.locale

    # Convert activities to events, and mark activities where the member is
    # is enrolled as reservist
    @reservist_activity_ids = @member.reservist_activities.ids
    events = @member.activities.map do |a|
      if @reservist_activity_ids.include? a.id
        a.name = "[RESERVIST] #{a.name}"
      end
      IcalendarHelper.activityToEvent(a, @locale)
    end

    # Return the calendar
    IcalendarHelper.createCalendar(events, @locale).to_ical
  end
end
