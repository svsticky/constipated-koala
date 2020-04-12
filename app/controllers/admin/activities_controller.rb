#:nodoc:
class Admin::ActivitiesController < ApplicationController
  # replaced with calls in each of the methods
  # impressionist :actions => [ :create, :update, :destroy ]

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

    # Strip an activity name ffrom all characters banks do not support

    # Remove all non-ascii characters (no language extension)
    ascii_encoding_options = {
      :invalid => :replace,      # Replace invalid byte sequences
      :undef => :replace,        # Replace anything not defined in ASCII
      :replace => '',            # Use a blank for those replacements
      :universal_newline => true # Always break lines with \n
    }

    ascii = @activity.name.encode(Encoding.find('ASCII'), ascii_encoding_options)

    # Remove the other illegal characters
    # Non-printable characters are ignored
    # source: https://www.sepaforcorporates.com/sepa-implementation/valid-xml-characters-sepa-payments/
    @bank_name = ascii.delete "!\"#$%&*;<=>@[\\]^_`{|}~"
  end

  def create
    @activity = Activity.new(activity_post_params.except(:_destroy))

    if @activity.save
      impressionist @activity
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
      impressionist @activity
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
    impressionist @activity

    redirect_to activities_path
  end

  private

  def activity_post_params
    params.require(:activity).permit(:name,
                                     :description,
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
                                     :_destroy)
  end
end
