class Users::HomeController < ApplicationController
  skip_before_action :authenticate_admin!, only: [ :index ]
  before_action :set_locale
  
  layout nil

  def index
    @member = Member.find(current_user.credentials_id)
  end

  private

  def set_locale
    session['locale'] = params[:l] || session['locale'] || I18n.default_locale
    I18n.locale = session['locale']
  end
end