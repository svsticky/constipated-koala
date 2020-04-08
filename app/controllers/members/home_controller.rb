#:nodoc:
class Members::HomeController < ApplicationController
  skip_before_action :authenticate_admin!
  skip_before_action :authenticate_user!, only: [:confirm_add_funds]

  layout 'members'

  def index
    @member = Member.find(current_user.credentials_id)
    @activities = Activity.upcoming.take(2)

<<<<<<< HEAD
    @pinned = Post.published.pinned
    @unpinned = Post.published.unpinned
=======
    # information of the middlebar
    @balance = CheckoutBalance.find_by_member_id(current_user.credentials_id)
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

    # @participants =
    #   (
    #    @member.activities
    #      .study_year( params['year'] )
    #      .distinct
    #      .joins(:participants)
    #      .where(:participants => { :member => @member }) \
    #    +
    #     @member.activities
    #       .joins(:participants)
    #       .where("participants.paid = FALSE AND participants.price > 0")
    #    ).uniq
    #      .sort_by(&:start_date)
    #      .reverse!

    @years = (@member.join_date.study_year..Date.today.study_year).map { |year| ["#{ year }-#{ year + 1 }", year] }.reverse
    @participants =
      @member.activities
             .study_year(params['year'])
             .distinct
             .joins(:participants)
             .where(:participants => { member: @member, reservist: false })
             .order('start_date DESC')

    @transactions = CheckoutTransaction.where(:checkout_balance => CheckoutBalance.find_by_member_id(current_user.credentials_id)).order(created_at: :desc).limit(10)
    @transaction_costs = Settings.mongoose_ideal_costs
  end

  def edit
    @member = Member.includes(:educations).includes(:tags).find(current_user.credentials_id)
    @applications = [] # TODO: Doorkeeper::Application.authorized_for(current_user)

    @member.educations.build(:id => '-1') if @member.educations.empty?
  end

  def revoke
    Doorkeeper::AccessToken.revoke_all_for params[:id], current_user
    redirect_to :users_edit
  end

  def update
    @member = Member.find(current_user.credentials_id)

    if @member.update member_post_params.except 'mailchimp_interests'
      MailchimpJob.perform_later @member.email, @member, params[:member][:mailchimp_interests].select { |_, val| val == '1' }.keys unless
        ENV['MAILCHIMP_DATACENTER'].nil?

      impressionist(@member, 'lid bewerkt')

      redirect_to users_root_path
      return
    end

    @applications = [] # TODO: Doorkeeper::Application.authorized_for(current_user)
>>>>>>> 15f5ad9fbff98f81245039c7b301029810c4b1cc

    @debt = @member.participants.debt
    @balance = CheckoutBalance.find_by_member_id(current_user.credentials_id)

    @attending = @member.participants.upcoming.includes(:activity)
  end
end
