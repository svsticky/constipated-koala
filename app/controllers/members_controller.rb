class MembersController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :authenticate_user!
  before_action :set_locale

  layout 'members'

  def set_locale
    session['locale'] = params[:l] || session['locale'] || I18n.default_locale
    I18n.locale = session['locale']
  end
end
