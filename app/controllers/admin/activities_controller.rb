#:nodoc:
class Admin::ActivitiesController < ApplicationController
  impressionist actions: [:update, :destroy]

  def index
    @activities = Activity.study_year(params['year']).order(start_date: :desc)
    @years = (Activity.take(1).first.start_date.year..Date.today.study_year).map do |year|
      ["#{ year }-#{ year + 1 }", year]
    end.reverse

    @activity = Activity.new
  end

  def weekoverzicht(locale)
    @weekoverzicht = (["**#{ t('admin.activities.weekoverzicht', locale: locale) }**"] + (0..4).map do |n|
      week_day = Date.current.beginning_of_week + n.days
      acs = Activity.where(start_date: week_day).all
      next if acs.empty?

      res = "**#{ l(acs[0].start_date, format: '%A', locale: locale).capitalize }**\n"
      res + acs.map do |ac|
        ac_string = "\n"
        ac_string += locale == :nl ? ac.description_nl : ac.description_en
        ac_string += "\n\nhttps://koala.svsticky.nl/activities/#{ ac.id }\n"
        ac_string
      end.join("\n&\n")
    end).join("\n")
  end
  helper_method :weekoverzicht

  def show
    @is_summarized = params['summary_only'] || params['summary_csv']
    @is_summarized_as_csv = params['summary_csv']
    @activity = Activity.find(params[:id])
    @recipients = @activity.payment_mail_recipients
    @attendees  = @activity.ordered_attendees
    @reservists = @activity.ordered_reservists
  end

  def create
    @activity = Activity.new(activity_post_params.except(:_destroy))

    if @activity.save
      # manual call to impressionist, because otherwise the activity doesn't have an id yet
      impressionist(@activity)
      redirect_to(@activity)
    else
      @activities = Activity.all.order(start_date: :desc)
      @years = (Activity.take(1).first.start_date.year..Date.today.study_year).map do |year|
        ["#{ year }-#{ year + 1 }", year]
      end.reverse

      @detailed = Activity.debtors.sort_by(&:start_date).reverse!

      render('index')
    end
  end

  # returns the data needed to add the members via javascript
  def committee_members
    @activity = Activity.find(params[:activity_id])
    @committee_members = @activity.group.members
    @member = @committee_members.map do |member|
      member = Member.find_by(id: member.member_id)
      {
        id: params[:activity_id],
        member: {
          id: member.id,
          name: member.name,
          email: member.email
        },
        activity: @activity
      }
    end
    render(json: @member)
  end

  # TODO: refactor
  def update
    @activity = Activity.find(params[:id])
    params = activity_post_params

    # removing the images from disk
    if params[:_destroy] == 'true'
      logger.debug('remove poster from activity')
      @activity.poster.purge
    end

    if @activity.update(params.except(:_destroy))
      redirect_to(@activity)
    else
      @recipients = @activity.payment_mail_recipients
      @attendees  = @activity.ordered_attendees
      @reservists = @activity.ordered_reservists
      render('show')
    end
  end

  def destroy
    @activity = Activity.find(params[:id])
    @activity.destroy

    redirect_to(activities_path)
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
                                     :open_date,
                                     :open_time,
                                     :unenroll_date,
                                     :payment_deadline,
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
                                     :is_payable,
                                     :VAT,
                                     :show_on_website,
                                     :is_masters,
                                     :is_freshmans,
                                     :is_sophomores,
                                     :is_seniors,
                                     :participant_limit,
                                     :show_participants,
                                     :_destroy)
  end
end
