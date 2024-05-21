require 'icalendar_helper'

class CalendarsController < ActionController::Base

  # supply the personalised iCal feed from the user
  # TODO supporting WebDAV might be nat, but not needed
  def show
    # TODO reservist marker
    # TODO only display future activities option
    # TODO multilingual/optional description

    # respond_to do |format|
    #   format.ics {
    #      render plain: create_calendar,
    #       content_type: 'text/calendar'
    #   }
    # end
    respond_to do |format|
      format.ics {
        send_data create_calendar,
        type: 'text/calendar',
        disposition: 'attachment',
        filename: "#{@member.first_name}_activities.ics"
      }
    end


    # send_file calendar_path, type: 'text/calendar', disposition: 'attachment'
    # else
    #   render json: { error: "Unkown hash" }, status: :not_found
    # end
  end

  def create_calendar
    @member = Member.find_by(calendar_id: params[:calendar_id])
    events = @member.activities.map { |a| IcalendarHelper.activityToEvent(a) }
    IcalendarHelper.createCalendar(events).to_ical
  end
end
