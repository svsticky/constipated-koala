#:nodoc:
class Members::HomeController < ApplicationController
  skip_before_action :authenticate_admin!
  skip_before_action :authenticate_user!, only: [:confirm_add_funds]

  layout 'members'

  def index
    @member = Member.find(current_user.credentials_id)
    @activities = Activity.upcoming.take(2)

    @pinned = Post.pinned
    @posts = Post.published

    @debt = Participant
            .where(paid: false, member: @member, reservist: false)
            .joins(:activity)
            .where('activities.start_date < NOW()')
            .sum(:price) \
     + Participant
            .where(paid: false, price: nil, member: @member, reservist: false)
            .joins(:activity)
            .where('activities.start_date < NOW()')
            .sum('activities.price ') # TODO make this a function of the participant class?

    @balance = CheckoutBalance.find_by_member_id(current_user.credentials_id)
  end

  def add_funds
    member = Member.find(current_user.credentials_id)
    balance = CheckoutBalance.find_or_create_by!(member: member)

    if ideal_transaction_params[:amount].to_f <= Settings.mongoose_ideal_costs
      flash[:notice] = I18n.t('failed', scope: 'activerecord.errors.models.ideal_transaction')
      redirect_to members_home_path
      return
    end

    if balance.nil?
      flash[:notice] = I18n.t('failed', scope: 'activerecord.errors.models.ideal_transaction')
      redirect_to members_home_path
      return
    end

    ideal = IdealTransaction.new(
      :description => 'Mongoose-tegoed',
      :amount => (ideal_transaction_params[:amount].to_f + Settings.mongoose_ideal_costs),
      :issuer => ideal_transaction_params[:bank],
      :member => member,

      :transaction_id => nil,
      :transaction_type => 'CheckoutTransaction',

      :redirect_uri => users_root_url
    )

    if ideal.save
      redirect_to ideal.mollie_uri
    else
      flash[:notice] = I18n.t('failed', scope: 'activerecord.errors.models.ideal_transaction')
      redirect_to members_home_path
    end
  end


  private

  def ideal_transaction_params
    params.require(:ideal_transaction).permit(:bank, :amount)
  end
end
