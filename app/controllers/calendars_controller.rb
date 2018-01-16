class CalendarsController < ActionController::Base
  def show
    respond_to do |format|
      format.ics do
        @Calendar = Icalendar::Calendar.new
        @Calendar.x_wr_calname = 'Sticky Activities'

        update_calendar(@Calendar)

        render plain: @Calendar.to_ical
        puts @Calendar.to_ical
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
    st = activity.start_time
    sd = activity.start_date
    et = activity.end_time
    ed = activity.end_date

    if st
      @sdt = DateTime.new(sd.year, sd.month, sd.day, st.hour, st.min, st.sec, st.zone)
      @edt = DateTime.new(ed.year, ed.month, ed.day, et.hour, et.min, et.sec, et.zone)
    else
      @sdt = Date.new(sd.year, sd.month, sd.day)
      if ed.day == sd.day
        @edt = Date.new(ed.year, ed.month, ed.day + 1)
      else
        @edt = Date.new(ed.year, ed.month, ed.day)
      end
    end

    event = Icalendar::Event.new
    event.dtstart = @sdt
    event.dtend = @edt
    event.summary = activity.name
    event.url = activity_url(activity)
    unless activity.description.nil?
      event.description = activity.description + '\n'
    end
    event.location = activity.location
    unless activity.price.nil? || activity.price == 0
      event.description += "Price: €" + activity.price.to_s
    end
    event.alarm do |a|
      a.trigger = "-PT2H"
      a.summary = activity.description
    end
    calendar.add_event(event)
  end
end
