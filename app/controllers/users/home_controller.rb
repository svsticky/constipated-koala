class Users::HomeController < ApplicationController
  skip_before_action :authenticate_admin!, only: [ :index ]
  before_action :set_locale
  

  def index
    @member = Member.find(current_user.credentials_id)
    @activities = (@member.activities.joins(:participants).where(:participants => { :paid => false, :member => @member } ).distinct + @member.activities.order(start_date: :desc).limit(10)).uniq.sort_by(&:start_date).reverse
    @transactions = CheckoutTransaction.where( :checkout_balance => CheckoutBalance.find_by_member_id(current_user.credentials_id)).order(created_at: :desc).limit(10)
  end

  private

  def set_locale
    session['locale'] = params[:l] || session['locale'] || I18n.default_locale
    I18n.locale = session['locale']
  end
end