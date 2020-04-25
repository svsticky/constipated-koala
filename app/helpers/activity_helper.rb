# Formatting dates for activities
module ActivityHelper
  def format_date(activity, format: "%A %d %B %Y")
    # multi-day activity
    return "#{ I18n.l(activity.start_date, format: format) } - #{ I18n.l(activity.end_date, format: format) }" if activity.start_date != activity.end_date

    # single day activity
    return I18n.l(activity.start_date, format: format).to_s
  end

  def format_time(activity, format: "%H:%M", display_end: true)
    return "#{ activity.start_time&.strftime(format) } - #{ activity.end_time&.strftime(format) }" if display_end

    return activity.start_time&.strftime(format).to_s
  end
end
