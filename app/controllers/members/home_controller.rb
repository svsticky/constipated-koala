#:nodoc:
class Members::HomeController < ApplicationController
  skip_before_action :authenticate_admin!
  skip_before_action :authenticate_user!, only: [:confirm_add_funds]

  layout 'members'

  def index
    @member = Member.find(current_user.credentials_id)

    # information of the middlebar
    @balance = CheckoutBalance.find_by(member_id: current_user.credentials_id)
    @debt = Participant
            .where(paid: false, member: @member, reservist: false)
            .joins(:activity)
            .where('activities.is_payable')
            .sum(:price) \
     + Participant # The plus makes it work for all activities where the member does NOT have a modified price.
            .where(paid: false, price: nil, member: @member, reservist: false)
            .joins(:activity)
            .where('activities.is_payable')
            .sum('activities.price ')

    @posts_array = Post.published.pinned + Post.published.unpinned.order(:published_at)
    @pagination, @posts = pagy_array(@posts_array, items: 10)

    @years = (@member.join_date.study_year..Date.today.study_year).map do |year|
      ["#{ year }-#{ year + 1 }", year]
    end.reverse
    @participants =
      @member.activities
             .study_year(params['year'])
             .distinct
             .joins(:participants)
             .where(participants: { member: @member, reservist: false })
             .order('start_date DESC')

    @transactions = CheckoutTransaction.where(
      checkout_balance: CheckoutBalance.find_by(
        member_id: current_user.credentials_id
      )
    ).order(created_at: :desc).limit(10) # ParticipantTransaction.all #
    @transaction_costs = Settings.mongoose_ideal_costs
  end

  def edit
    @member = Member.includes(:educations).includes(:tags).find(current_user.credentials_id)
    @user = User.find_by(email: current_user.email)
    @applications = [] # TODO: Doorkeeper::Application.authorized_for(current_user)

    @member.educations.build(id: '-1') if @member.educations.empty?
  end

  def revoke
    Doorkeeper::AccessToken.revoke_all_for(params[:id], current_user)
    redirect_to(:users_edit)
  end

  def update
    @user = User.find_by(email: current_user.email)
    @user.update(user_post_params)

    @member = Member.find(current_user.credentials_id)

    if @member.update(member_post_params.except('mailchimp_interests'))
      unless ENV['MAILCHIMP_DATACENTER'].blank? || member_post_params[:mailchimp_interests].nil?
        MailchimpJob.perform_later(@member.email, @member, (member_post_params[:mailchimp_interests].select do |_, val|
                                                              val == '1'
                                                            end))
      end

      impressionist(@member, I18n.t('activerecord.attributes.impression.member.update'))

      cookies["locale"] = @user.language

      redirect_to(users_edit_path, notice: I18n.t('members.home.edit.profile_saved'))
      return
    end

    @applications = [] # TODO: Doorkeeper::Application.authorized_for(current_user)

    render('edit')
    return
  end

  def download
    @member = Member.includes(:activities, :groups, :educations).find(current_user.credentials_id)
    @transactions = CheckoutTransaction.where(
      checkout_balance: CheckoutBalance.find_by(member_id: current_user.credentials_id)
    ).order(created_at: :desc)

    send_data(render_to_string(layout: false),
              filename: "#{ @member.name.downcase.tr(' ', '-') }.html",
              type: 'application/html',
              disposition: 'attachment')
  end

  private

  def member_post_params
    params.require(:member).permit(:address,
                                   :house_number,
                                   :postal_code,
                                   :city,
                                   :phone_number,
                                   :emergency_phone_number,
                                   :email,
                                   mailchimp_interests: {},
                                   educations_attributes: [:id, :status])
  end

  def transaction_params
    params.permit(:amount, :issuer, :payment_type)
  end

  def user_post_params
    params.require(:member).permit(:language)
  end
end
