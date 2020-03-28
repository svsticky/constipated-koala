#:nodoc:
class Members::HomeController < ApplicationController
  skip_before_action :authenticate_admin!
  skip_before_action :authenticate_user!, only: [:confirm_add_funds]

  layout 'members'

  def index
    @member = Member.find(current_user.credentials_id)
    @activities = Activity.upcoming.take(2)

    @pinned = Post.published.pinned
    @posts = Post.published

    @debt = @member.participants.debt
    @balance = CheckoutBalance.find_by_member_id(current_user.credentials_id)

    @attending = @member.participants.upcoming.includes(:activity)
  end
end
