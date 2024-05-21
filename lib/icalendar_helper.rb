require 'icalendar' # https://github.com/icalendar/icalendar

#:nodoc:
module IcalendarHelper
  # Converts a sticky activity to an iCalendar event
  def IcalendarHelper.activityToEvent(activity)
    event = Icalendar::Event.new
    event.uid = activity.id.to_s
    event.dtstart = activity.start_date
    event.dtend = activity.end_date
    event.summary = activity.name
    event.description = activity.description_nl # TODO localise
    event.location = activity.location
    return event
  end

  # Combines zero or more Icalendar events into an iCalendar abstract object
  def IcalendarHelper.createCalendar(events)
    calendar = Icalendar::Calendar.new
    calendar.x_wr_calname = "Sticky Activiteiten" # TODO localise
    events.each { |e| calendar.add_event(e) }
    calendar.publish
    return calendar
    # Returns the abstract icalendar object, not the ICS string ready to
    # be stored in an ICS file. To convert this calendar into an ICS string,
    # use `calendar.to_ical` or the `createFile` method below.
  end

  # Stores the calendar to an *.ics file
  def IcalendarHelper.createFile(calendar, path)
    calendar_string = calendar.to_ical
    File.open(path, 'w') do |file|
      file.write(calendar_string)
    end
  end

  # TODO allow updating a calendar file, to preserve uids.
  # This enables the calendar client to recognise which events are new
end

