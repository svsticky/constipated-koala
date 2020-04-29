#:nodoc:
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Moved the authentication requirement to the application controller
  before_action :authenticate_user!
  before_action :authenticate_admin!

  before_action :set_locale

  protected

  def after_sign_in_path_for(resource)
    I18n.locale = resource.language
    return users_root_path(l: resource.language)
  end

  def authenticate_admin!
    if !current_user.nil? && !current_user.admin?
      head :forbidden
      return
    end
  end

  def set_locale
    session['locale'] = current_user.language unless current_user.nil?
    session['locale'] = session['locale'] || I18n.default_locale
    I18n.locale = session['locale']
  end
end
