#:nodoc:
class Members::HomeController < ApplicationController
  skip_before_action :authenticate_admin!
  skip_before_action :authenticate_user!, only: [:confirm_add_funds]

  layout 'members'

  def index
    @member = Member.find(current_user.credentials_id)

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

    @transactions = CheckoutTransaction.where(:checkout_balance => CheckoutBalance.find_by_member_id(current_user.credentials_id)).order(created_at: :desc).limit(10) #ParticipantTransaction.all #
    @payconiq_transaction_costs = Settings.payconiq_transaction_costs
    @transaction_costs = Settings.mongoose_ideal_costs
  end

  def edit
    @member = Member.includes(:educations).includes(:tags).find(current_user.credentials_id)
    @user = User.find_by_email(current_user.email)
    @applications = [] # TODO: Doorkeeper::Application.authorized_for(current_user)

    @member.educations.build(:id => '-1') if @member.educations.empty?
  end

  def revoke
    Doorkeeper::AccessToken.revoke_all_for params[:id], current_user
    redirect_to :users_edit
  end

  def update
    @user = User.find_by_email(current_user.email)
    @user.update(user_post_params)

    @member = Member.find(current_user.credentials_id)

    if @member.update member_post_params.except 'mailchimp_interests'
      MailchimpJob.perform_later @member.email, @member, (member_post_params[:mailchimp_interests].select { |_, val| val == '1' }) unless
        ENV['MAILCHIMP_DATACENTER'].blank? || member_post_params[:mailchimp_interests].nil?

      impressionist(@member, I18n.t('activerecord.attributes.impression.member.update'))

      cookies["locale"] = @user.language

      # the translation location was used here but that conflicted with the way
      # the translation was shown, as it was tried to translate it again there
      flash[:warning] = I18n.t('members.home.edit.email_confirmation') if @member.email != params[:member][:email]
      redirect_to users_edit_path, :notice => I18n.t('members.home.edit.profile_saved')
      return
    end

    @applications = [] # TODO: Doorkeeper::Application.authorized_for(current_user)

    render 'edit'
    return
  end
  def pay_activities
    member = Member.find(current_user.credentials_id)
    unpaid = Participant
                .where(paid: false, member: member, reservist: false)
                .joins(:activity)
                .where('activities.start_date < NOW()')
                .select {|n| params[:activity_ids].map(&:to_i).include? n.activity_id}

    amount = unpaid.sum(&:currency)

    if transaction_params[:payment_type] == "Payconiq"
      payconiq = Payment.new(
        :description => 'Activiteiten-betaling',
        :amount => amount,
        :member => member,
        :payment_type => :payconiq_online,
        :transaction_id => unpaid.pluck(:activity_id),
        :transaction_type => :activity
      )
      if payconiq.save
        render :json => { qrurl: payconiq.payconiq_qrurl, amount: payconiq.amount, deeplink: payconiq.payconiq_deeplink }.to_json
      else
        flash[:notice] = I18n.t('failed', scope: 'activerecord.errors.models.ideal_transaction')
        redirect_to members_home_path
      end
    else
      ideal = Payment.new(
        :description => I18n.t('activerecord.errors.models.ideal_transaction.attributes.checkout'),
        :amount => (transaction_params[:amount].to_f + Settings.mongoose_ideal_costs),
        :issuer => transaction_params[:bank],
        :member => member,
        :payment_type => :ideal,
        :transaction_id => unpaid.pluck(:activity_id),
        :transaction_type => :activity,

        :ideal_redirect_uri => users_root_url
      )

      if ideal.save
        redirect_to ideal.ideal_uri
      else
        flash[:notice] = I18n.t('failed', scope: 'activerecord.errors.models.ideal_transaction')
        redirect_to members_home_path
      end
    end
  end
  def add_funds
    member = Member.find(current_user.credentials_id)
    balance = CheckoutBalance.find_or_create_by!(member: member)

    if transaction_params[:amount].to_f <= Settings.mongoose_ideal_costs
      flash[:notice] = I18n.t('failed', scope: 'activerecord.errors.models.ideal_transaction')
      redirect_to members_home_path
      return
    end

    if balance.nil?
      flash[:notice] = I18n.t('failed', scope: 'activerecord.errors.models.ideal_transaction')
      redirect_to members_home_path
      return
    end

    if transaction_params[:payment_type] == "Payconiq"
      payment = Payment.new(
        :description => I18n.t('activerecord.errors.models.ideal_transaction.attributes.checkout'),
        :amount => transaction_params[:amount].to_f,
        :member => member,
        :payment_type => :payconiq_online,

        :transaction_id => nil,
        :transaction_type => :checkout
      )

      if payment.save
        render :json => { payconiq_qrurl: payment.payconiq_qrurl, amount: payment.amount, payconiq_deeplink: payment.payconiq_deeplink }
      else
        flash[:notice] = I18n.t('failed', scope: 'activerecord.errors.models.ideal_transaction')
        redirect_to members_home_path
      end
    else
      payment = Payment.new(
        :description => I18n.t('activerecord.errors.models.ideal_transaction.attributes.checkout'),
        :amount => transaction_params[:amount].to_f,
        :issuer => transaction_params[:bank],
        :member => member,
        :payment_type => :ideal,

        :transaction_id => nil,
        :transaction_type => :checkout,

        :ideal_redirect_uri => users_root_url
      )

      if payment.save
        redirect_to ideal.ideal_uri
      else
        flash[:notice] = I18n.t('failed', scope: 'activerecord.errors.models.ideal_transaction')
        redirect_to members_home_path
      end
    end
  end

  def download
    @member = Member.includes(:activities, :groups, :educations).find(current_user.credentials_id)
    @transactions = CheckoutTransaction.where(:checkout_balance => CheckoutBalance.find_by_member_id(current_user.credentials_id)).order(created_at: :desc)

    send_data render_to_string(:layout => false),
              :filename => "#{ @member.name.downcase.tr(' ', '-') }.html",
              :type => 'application/html',
              :disposition => 'attachment'
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
                                   :mailchimp_interests => {},
                                   educations_attributes: [:id, :status])
  end

  def transaction_params
    params.permit(:amount, :issuer, :payment_type)
  def user_post_params
    params.require(:member).permit(:language)
  end
end
