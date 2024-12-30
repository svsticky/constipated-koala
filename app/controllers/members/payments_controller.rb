#:nodoc:
class Members::PaymentsController < ApplicationController
  skip_before_action :authenticate_admin!
  skip_before_action :authenticate_user!, only: [:confirm_add_funds]

  layout 'members'
  def index
    @member = Member.find(current_user.credentials_id)
    @participants = @member.unpaid_activities
    @transactions = CheckoutTransaction.where(
      checkout_balance: CheckoutBalance.find_by(
        member_id: current_user.credentials_id
      )
    ).order(created_at: :desc).limit(10) # ParticipantTransaction.all #
    @transaction_costs = Settings.mongoose_ideal_costs
  end

  def pay_activities
    member = Member.find(current_user.credentials_id)
    unpaid = Participant
             .where(activity_id: params[:activity_ids], member: member, reservist: false)
             .joins(:activity)
             .where(activities: { is_payable: true })
    activity_names_for_unpaid = unpaid.map { |p| p.activity.name }

    description_prefix = "Activiteiten - "
    description_length_remaining = 140 - description_prefix.length
    description = "#{ description_prefix }#{ self.class.join_with_char_limit(
      activity_names_for_unpaid, ', ', description_length_remaining
    ) }"
    amount = unpaid.sum(&:currency)

    if amount < 1
      flash[:warning] = I18n.t('failed', scope: 'activerecord.errors.models.payment')
      redirect_to(member_payments_path)
      return
    end

    payment = Payment.new(
      description: description,
      amount: amount,
      member: member,
      payment_type: :ideal,
      transaction_id: unpaid.pluck(:activity_id),
      transaction_type: :activity,
      redirect_uri: member_payments_path
    )

    if payment.save
      # Check URI for safety (supresses brakeman warning)
      url = begin
        URI.parse(payment.payment_uri)
      rescue StandardError
        nil
      end

      # Check if it's a valid URI and matches your whitelist of acceptable domains (e.g., only http(s)://example.com)
      if url.is_a?(URI::HTTP) && [
          'www.mollie.com', # staging
          'pay.ideal.nl', # production
        ].include?(url.host)
        redirect_to(url.to_s)
      else
        # Fallback to a safe default redirect if the URI is invalid or not in the whitelist
        redirect_to(root_path)
      end
    else
      flash[:notice] = I18n.t('failed', scope: 'activerecord.errors.models.payment')
      redirect_to(member_payments_path)
    end
  end

  def self.join_with_char_limit(collection, separator, maxlength)
    all_joined = collection.join(separator)
    return all_joined if all_joined.length <= maxlength

    suffix_mkr = ->(cnt) { " & #{ cnt } meer" }
    remaining_length = maxlength - (collection[0].length + suffix_mkr.call(collection.length).length)

    return ".. & #{ collection.length } meer" if remaining_length < 0

    index = 0
    while index < collection.length - 1
      index += 1
      remaining_length -= collection[index].length + separator.length
      if remaining_length < 0
        slice = collection.slice(0, index)
        return "#{ slice.join(separator) } & #{ collection.length - index } meer"
      end
    end

    return ".. & #{ collection.length } meer"
  end

  def add_funds
    member = Member.find(current_user.credentials_id)
    balance = CheckoutBalance.find_or_create_by!(member: member)
    description = I18n.t('activerecord.errors.models.payment.attributes.checkout')
    amount =  transaction_params[:amount].gsub(",", ".").to_f

    if amount < 1
      flash[:warning] = I18n.t('failed', scope: 'activerecord.errors.models.payment')
      redirect_to(member_payments_path)
      return
    end

    if balance.nil?
      flash[:warning] = I18n.t('failed', scope: 'activerecord.errors.models.payment')
      redirect_to(member_payments_path)
      return
    end

    payment = Payment.new(
      description: description,
      amount: amount,
      member: member,
      payment_type: :ideal,
      transaction_id: nil,
      transaction_type: :checkout,
      redirect_uri: member_payments_path
    )

    if payment.save
      # Check URI for safety (supresses brakeman warning)
      url = begin
        URI.parse(payment.payment_uri)
      rescue StandardError
        nil
      end

      # Check if it's a valid URI and matches your whitelist of acceptable domains (e.g., only http(s)://example.com)
      if url.is_a?(URI::HTTP) && ['mollie.com'].include?(url.host)
        redirect_to(url)
      else
        # Fallback to a safe default redirect if the URI is invalid or not in the whitelist
        redirect_to(root_path)
      end
    else
      flash[:warning] = I18n.t('failed', scope: 'activerecord.errors.models.payment')
      redirect_to(members_home_path)
    end
  end

  private

  def transaction_params
    params.permit(:amount, :activity_ids, :payment_type)
  end
end
