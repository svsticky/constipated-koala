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
    @participants = @member.unpaid_activities
    @transactions = CheckoutTransaction.where(:checkout_balance => CheckoutBalance.find_by_member_id(current_user.credentials_id)).order(created_at: :desc).limit(10) # ParticipantTransaction.all #
    @payconiq_transaction_costs = Settings.payconiq_transaction_costs
    @transaction_costs = Settings.mongoose_ideal_costs
  end

  def pay_activities
    member = Member.find(current_user.credentials_id)
    unpaid = Participant
             .where(activity_id: params[:activity_ids], member: member, reservist: false)
             .joins(:activity)
             .where(:activities => { is_payable: true })
    description = "Activiteiten - #{ unpaid.map { |p| p.activity.id.to_s } }"
    amount = unpaid.sum(&:currency)
    payment = Payment.new(
      :description => description,
      :amount => amount,
      :issuer => transaction_params[:payment_type] == 'Ideal' ? transaction_params[:bank] : nil,
      :member => member,
      :payment_type => transaction_params[:payment_type] == 'Payconiq' ? :payconiq_online : :ideal,
      :transaction_id => unpaid.pluck(:activity_id),
      :transaction_type => :activity,
      :redirect_uri => member_payments_path
    )
    if payment.save
      redirect_to payment.payment_uri
    else
      flash[:notice] = I18n.t('failed', scope: 'activerecord.errors.models.payment')
      redirect_to member_payments_path
    end
  end

  def add_funds
    member = Member.find(current_user.credentials_id)
    balance = CheckoutBalance.find_or_create_by!(member: member)
    description = I18n.t('activerecord.errors.models.payment.attributes.checkout')
    amount =  transaction_params[:amount].gsub(",",".").to_f
    if amount <= Settings.mongoose_ideal_costs || amount < 1
      flash[:warning] = I18n.t('failed', scope: 'activerecord.errors.models.payment')
      redirect_to member_payments_path
      return
    end

    if balance.nil?
      flash[:warning] = I18n.t('failed', scope: 'activerecord.errors.models.payment')
      redirect_to member_payments_path
      return
    end

    payment = Payment.new(
      :description => description,
      :amount => amount,
      :member => member,
      :issuer => transaction_params[:payment_type] == 'Ideal' ? transaction_params[:bank] : nil,
      :payment_type => transaction_params[:payment_type] == "Payconiq" ? :payconiq_online : :ideal,

      :transaction_id => nil,
      :transaction_type => :checkout,
      :redirect_uri => member_payments_path
    )
    if payment.save
      redirect_to payment.payment_uri
    else
      flash[:warning] = I18n.t('failed', scope: 'activerecord.errors.models.payment')
      redirect_to members_home_path
    end
  end

  private

  def transaction_params
    params.permit(:amount, :bank, :activity_ids, :payment_type)
  end
end