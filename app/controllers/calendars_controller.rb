class CalendarsController < ActionController::Base
  def show
    respond_to do |format|
      format.ics do
        @Calendar = Icalendar::Calendar.new
        @Calendar.x_wr_calname = 'Sticky Activities'

        update_calendar(@Calendar)

        render plain: @Calendar.to_ical
      end
      format.html do
        render html:
          "<strong>Not available as html page</strong>
          <br>Go <a href='webcal://koala.svsticky.nl/calendarfeed.ics'>here</a>
          to subscribe to activities".html_safe
      end
    end
  end

  def update_calendar(calendar)
    @activities = Activity.where(
      '(end_date IS NULL AND start_date >= ?) OR end_date >= ?',
        Date.today, Date.today
      ).where(is_viewable: true).order(:start_date)

    @activities.each do |a|
      create_event(a, @Calendar)
    end

    calendar.publish
  end

  def create_event(activity, calendar)
    event = Icalendar::Event.new
    event.dtstart = activity.start
    event.dtend = activity.end
    event.summary = activity.name
    event.url = activity_url(activity)

    unless activity.description.nil?
      event.description = activity.description + '\n'
    end

    event.location = activity.location

    unless activity.price.nil? || activity.price == 0
      if activity.description.nil?
        event.description = "Price: €" + activity.price.to_s
      else
        event.description += "Price: €" + activity.price.to_s
      end
    end

    event.alarm do |a|
      a.trigger = "-PT2H"
      a.summary = activity.description
    end

    calendar.add_event(event)
  end
end
