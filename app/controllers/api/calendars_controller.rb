require 'icalendar_helper'

# Controller for all calendar related endpoints
class Api::CalendarsController < ActionController::Base
  # supply the personalised iCal feed from the user
  def show
    @member = Member.find_by(calendar_id: params[:calendar_id])
    # member variable will be accessible in other methods as well now

    unless @member # No member with the specified hash was found
      render(json: { error: I18n.t('calendars.errors.unkown_hash') }, status: :not_found)
      return
    end

    # If the HTTP request is a HEAD type, return the headers only
    if request.head?
      head(:ok)
      return
    end

    respond_to do |format|
      format.ics do
        send_data(create_personal_calendar,
                  type: 'text/calendar',
                  disposition: 'attachment',
                  filename: "#{ @member.first_name }_#{ I18n.t('calendars.jargon.activities') }.ics")
      end
    end
  end

  def index
    if current_user.nil?
      render(json: { error: I18n.t('calendars.errors.not_logged_in') }, status: :forbidden)
      return
    end

    @member = Member.find(current_user.credentials_id)
    render(plain: url_for(action: 'show', calendar_id: @member.calendar_id), format: :ics)
  end

  # Not exposed to API directly, but through #show
  def create_personal_calendar
    # Convert activities to events, and mark activities where the member is
    # is enrolled as reservist
    @reservist_activity_ids = @member.reservist_activities.ids
    events = @member.activities.map do |a|
      if @reservist_activity_ids.include?(a.id)
        a.name = "[#{ I18n.t('calendars.jargon.reservist').upcase }] #{ a.name }"
      end
      a.to_calendar_event(I18n.locale)
    end

    # Return the calendar
    IcalendarHelper.create_calendar(events, @locale).to_ical
  end
end
