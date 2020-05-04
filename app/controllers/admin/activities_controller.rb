#:nodoc:
class Admin::ActivitiesController < ApplicationController
  impressionist :actions => [:update, :destroy]

  def index
    @activities = Activity.study_year(params['year']).order(start_date: :desc)
    @years = (Activity.take(1).first.start_date.year..Date.today.study_year).map { |year| ["#{ year }-#{ year + 1 }", year] }.reverse

    @activity = Activity.new
  end

  def show
    @activity = Activity.find params[:id]
    @recipients = @activity.payment_mail_recipients
    @attendees  = @activity.ordered_attendees
    @reservists = @activity.ordered_reservists
  end

  def create
    @activity = Activity.new(activity_post_params.except(:_destroy))

    if @activity.save
      # manual call to impressionist, because otherwise the activity doesn't have an id yet
      impressionist(@activity)
      redirect_to @activity
    else
      @activities = Activity.all.order(start_date: :desc)
      @years = (Activity.take(1).first.start_date.year..Date.today.study_year).map { |year| ["#{ year }-#{ year + 1 }", year] }.reverse

      @detailed = Activity.debtors.sort_by(&:start_date).reverse!

      render 'index'
    end
  end

  # TODO: refactor
  def update
    @activity = Activity.find params[:id]
    params = activity_post_params

    # removing the images from disk
    if params[:_destroy] == 'true'
      logger.debug 'remove poster from activity'
      @activity.poster.purge
    end

    if @activity.update(params.except(:_destroy))
      redirect_to @activity
    else
      @recipients = @activity.payment_mail_recipients
      @attendees  = @activity.ordered_attendees
      @reservists = @activity.ordered_reservists
      render 'show'
    end
  end

  def destroy
    @activity = Activity.find params[:id]
    @activity.destroy

    redirect_to activities_path
  end

  private

  def activity_post_params
    params.require(:activity).permit(:name,
                                     :description_nl,
                                     :description_en,
                                     :start_date,
                                     :start_time,
                                     :end_date,
                                     :end_time,
                                     :unenroll_date,
                                     :comments,
                                     :price,
                                     :location,
                                     :poster,
                                     :organized_by,
                                     :notes,
                                     :notes_mandatory,
                                     :notes_public,
                                     :is_alcoholic,
                                     :is_enrollable,
                                     :is_viewable,
                                     :show_on_website,
                                     :is_masters,
                                     :is_freshmans,
                                     :participant_limit,
                                     :show_participants,
                                     :_destroy)
  end
end
