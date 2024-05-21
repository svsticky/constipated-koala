require 'icalendar_helper'

class Api::CalendarsController < ActionController::Base
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
    # end TODO 500 error if @member is empty
  end

  def index
    @member = Member.find(current_user.credentials_id) # TODO gives 500 error when not logged in
    render plain: "https://koala.svsticky.nl/api/calendar/pull/#{@member.calendar_id}" # TODO can this less hard-coded?
  end

  # Not exposed to API directly, but through #show
  def create_calendar
    @member = Member.find_by(calendar_id: params[:calendar_id])
    locale = I18n.locale # TODO werkt dit?
    events = @member.activities.map { |a| IcalendarHelper.activityToEvent(a, locale) }
    IcalendarHelper.createCalendar(events, locale).to_ical
  end
end
