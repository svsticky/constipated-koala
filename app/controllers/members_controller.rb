#:nodoc:
class MembersController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :authenticate_user!
  before_action :set_member!
  before_action :set_locale

  layout 'members'

  def set_locale
    session['locale'] = params[:l] || session['locale'] || I18n.default_locale
    I18n.locale = session['locale']
  end

  def set_member!
    @member = Member.find(current_user.credentials_id)
  end

  def set_activity!
    activity_id = params[:activity_id] || params[:id]
    @activity = Activity.find(activity_id)

    # Don't allow activities for old activities
    if @activity.ended? || !@activity.is_viewable? # rubocop:disable Style/GuardClause
      render :status => :gone,
             :plain => I18n.t(
               :activity_ended,
               scope: 'activerecord.errors.models.activity'
             )
    end
  end
end
