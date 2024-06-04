require 'icalendar' # https://github.com/icalendar/icalendar

# Includes all abstractions over iCalender representations
module IcalendarHelper

  # Combines zero or more Icalendar events into an iCalendar abstract object
  def self.create_calendar(events, locale)
    calendar = Icalendar::Calendar.new
    calendar.x_wr_calname = I18n.t("calendars.personalised_activities_calendar.name", locale: locale)
    events.each { |e| calendar.add_event(e) }
    calendar.publish
    return calendar
    # Returns the abstract icalendar object, not the ICS string ready to
    # be stored in an ICS file. To convert this calendar into an ICS string,
    # use `calendar.to_ical` or the `create_file` method below.
  end

  # Stores the calendar to an *.ics file
  def self.create_file(calendar, path)
    calendar_string = calendar.to_ical
    File.write(path, calendar_string)
  end
end
