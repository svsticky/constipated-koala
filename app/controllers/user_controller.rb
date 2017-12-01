class UserController < ApplicationController
  before_action :authenticate_user!
  before_action :set_locale

  def set_locale
    session['locale'] = params[:l] || session['locale'] || I18n.default_locale
    I18n.locale = session['locale']
  end
end