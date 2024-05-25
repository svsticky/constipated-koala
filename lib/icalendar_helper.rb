require 'icalendar' # https://github.com/icalendar/icalendar

# Includes all abstractions over iCalender representations
module IcalendarHelper
  # Converts a sticky activity to an iCalendar event
  def self.activity_to_event(activity, locale)
    event = Icalendar::Event.new
    event.uid = activity.id.to_s
    event.dtstart = activity.start_date
    event.dtend = activity.end_date
    event.summary = activity.name
    event.description = activity.description_localised(locale)
    event.location = activity.location
    return event
  end

  # Combines zero or more Icalendar events into an iCalendar abstract object
  def self.create_calendar(events, locale)
    calendar = Icalendar::Calendar.new
    calendar.x_wr_calname =
      case locale
      when :nl
        "Sticky Activiteiten"
      else
        "Sticky Activities"
      end
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
