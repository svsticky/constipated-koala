#:nodoc:
class Members::MembersController < ApplicationController
  skip_before_action :authenticate_admin!
  skip_before_action :authenticate_user!, only: [:confirm_add_funds]

  layout 'members'

  def show
    @member = Member.includes(:educations).includes(:tags).find(current_user.credentials_id)
    @participants = @member.activities
             .distinct
             .joins(:participants)
             .where(:participants => { member: @member, reservist: false })
             .order('start_date DESC')

    @transactions = CheckoutTransaction.where(:checkout_balance => CheckoutBalance.find_by_member_id(current_user.credentials_id)).order(created_at: :desc).limit(10)
  end

  def edit
    @member = Member.includes(:educations).includes(:tags).find(current_user.credentials_id)
    @applications = [] # TODO: Doorkeeper::Application.authorized_for(current_user)

    @member.educations.build(:id => '-1') if @member.educations.empty?
  end

  def update
    @member = Member.find(current_user.credentials_id)

    if @member.update member_post_params.except 'mailchimp_interests'
      MailchimpJob.perform_later @member.email, @member, params[:member][:mailchimp_interests].select { |_, val| val == '1' }.keys

      impressionist(@member, 'lid bewerkt')

      redirect_to current_member_path
      return
    end

    @applications = [] # TODO: Doorkeeper::Application.authorized_for(current_user)

    render 'edit'
    return
  end

  def download
    @member = Member.includes(:activities, :groups, :educations).find(current_user.credentials_id)
    @transactions = CheckoutTransaction.where(:checkout_balance => CheckoutBalance.find_by_member_id(current_user.credentials_id)).order(created_at: :desc)

    send_data render_to_string(:layout => false),
              :filename => "#{ @member.name.downcase.tr(' ', '-') }.html",
              :type => 'application/html',
              :disposition => 'attachment'
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
      redirect_to :current_member
    end
  end

  def revoke
    Doorkeeper::AccessToken.revoke_all_for params[:id], current_user
    redirect_to :current_member_edit
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
                                   :mailchimp_interests => [],
                                   educations_attributes: [:id, :status])
  end

  def ideal_transaction_params
    params.require(:ideal_transaction).permit(:bank, :amount)
  end
end
