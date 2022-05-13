#:nodoc:
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Moved the authentication requirement to the application controller
  before_action :authenticate_user!
  before_action :authenticate_admin!

  before_action :set_locale
  include Pagy::Backend

  protected

  def authenticate_admin!
    if !current_user.nil? && !current_user.admin?
      head(:forbidden)
      return
    end
  end

  def set_locale
    language = current_user.nil? ? I18n.default_locale : current_user.language
    session['locale'] = language
    I18n.locale = language
    cookies["locale"] = language
  end
end
