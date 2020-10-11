#:nodoc:
class Members::PaymentsController < ApplicationController
  skip_before_action :authenticate_admin!
  skip_before_action :authenticate_user!, only: [:confirm_add_funds]

  layout 'members'
  def index
    @member = Member.find(current_user.credentials_id)

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
    @participants =
      @member.payable_unpaid_activities

    @transactions = CheckoutTransaction.where(:checkout_balance => CheckoutBalance.find_by_member_id(current_user.credentials_id)).order(created_at: :desc).limit(10) # ParticipantTransaction.all #
    @payconiq_transaction_costs = Settings.payconiq_transaction_costs
    @transaction_costs = Settings.mongoose_ideal_costs
  end

  def pay_activities
    member = Member.find(current_user.credentials_id)
    unpaid = Participant
             .where(paid: false, member: member, reservist: false)
             .joins(:activity)
             .where(:activities => { is_payable: true })
             .select { |n| params[:activity_ids].map(&:to_i).include? n.activity_id }
    description = "Activiteiten - #{ unpaid.map{|p| "#{p.activity.id}"
    amount = unpaid.sum(&:currency)
    if transaction_params[:payment_type] == "Payconiq"
      payconiq = Payment.new(
        :description => description,
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
        :description => description,
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
    description = I18n.t('activerecord.errors.models.ideal_transaction.attributes.checkout')

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
        :description => description,
        :amount => transaction_params[:amount].to_f,
        :member => member,
        :payment_type => :payconiq_online,

        :transaction_id => nil,
        :transaction_type => :checkout
      )

      if payment.save
        render json: { qrurl: payment.payconiq_qrurl, amount: payment.amount, deeplink: payment.payconiq_deeplink }
      else
        flash[:notice] = I18n.t('failed', scope: 'activerecord.errors.models.ideal_transaction')
        redirect_to members_home_path
      end
    else
      payment = Payment.new(
        :description => description,
        :amount => transaction_params[:amount].to_f,
        :issuer => transaction_params[:bank],
        :member => member,
        :payment_type => :ideal,

        :transaction_id => nil,
        :transaction_type => :checkout,

        :ideal_redirect_uri => users_root_url
      )

      if payment.save
        redirect_to payment.ideal_uri
      else
        flash[:notice] = I18n.t('failed', scope: 'activerecord.errors.models.ideal_transaction')
        redirect_to members_home_path
      end
    end
  end

  private

  def transaction_params
    params.permit(:amount, :issuer, :payment_type)
  end

  def user_post_params
    params.require(:member).permit(:language)
  end
end
