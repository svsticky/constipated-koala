class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Moved the authentication requirement to the application controller
  before_action :authenticate_user!
  before_action :authenticate_admin!

  protected

  def authenticate_admin!
    if !current_user.nil? && !current_user.admin?
      head :forbidden
      return
    end
  end

  def member_information
    @member = Member.find(current_user.credentials_id)

    # information of the sidebar
    @balance = CheckoutBalance.find_by_member_id(current_user.credentials_id).balance
    @debt = Participant
            .where(paid: false, member: @member, reservist: false)
            .joins(:activity)
            .where('activities.start_date < NOW()')
            .sum(:price) \
     + Participant # The plus makes it work for all activities where the member does NOT have a modified price.
            .where(paid: false, price: nil, member: @member, reservist: false)
            .joins(:activity)
            .where('activities.start_date < NOW()')
            .sum('activities.price ')
  end
end
