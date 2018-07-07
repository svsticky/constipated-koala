# Public API creating an ical file which can be downloaded
class Api::CalendarsController < ApiController
  def show
    respond_to do |format|
      format.html
      format.ics do
        @activities = Activity.where(
          '(end_date IS NULL AND start_date >= ?) OR end_date >= ?',
          Date.today, Date.today
        ).where(is_viewable: true).order(:start_date)

        render plain: Activity.calendar(@activities)
      end
    end
  end
end
