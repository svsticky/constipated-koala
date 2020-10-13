#:nodoc:
class Admin::PaymentsController < ApplicationController
  def index
    @detailed = Activity.debtors.sort_by(&:start_date).reverse!
    @last_impressions = Activity.debtors.map do |activity|
      impression = Impression.where(impressionable_type: 'Activity').where(impressionable_id: activity.id).where(message: "mail").where('created_at > ?', activity.start).last

      days = if impression
               Integer(Date.today - impression.created_at.to_date)
             else
               "-"
             end
      [activity, days]
    end

    # Get checkout transactions that were purchased by pin of yesterday
    @checkout_transactions = CheckoutTransaction.where('DATE(checkout_transactions.created_at) = DATE(?) AND payment_method = \'Gepind\'', 1.days.ago).order(created_at: :desc)
    @dat = @checkout_transactions.map { |x| { member_id: x.checkout_balance.member.id, name: x.checkout_balance.member.name, price: x.price, date: x.created_at.to_date } }.to_json

    @payment_clipboard = get_payments
    # Get members of which the activities have been mailed 4 times, but haven't paid yet
    @late_activities = Activity.debtors.select { |activity| activity.impressionist_count(message: "mail", start_date: activity.start) >= 4 && activity.is_payble }
    @late_payments =
      @late_activities.map do |activity|
        activity.attendees.select do |participant|
          participant.paid == false && activity.is_payable &&
            (
              (participant.price && participant.price > 0) ||
              (participant.price.nil? &&
               activity.price && activity.price > 0)
            )
        end.map(&:member)
      end.flatten.uniq
  end

  def whatsapp_redirect
    @member = Member.find(params[:member_id])
    @activities = @member.unpaid_activities.where('activities.start_date <= ?', Date.today).distinct
    @participants = @activities.map { |a| Participant.find_by(member: @member, activity: a) }
    msg = render_to_string template: 'admin/members/payment_whatsapp.html.erb', layout: false, content_type: "text/plain"

    pn = @member.phone_number

    redirect_to "https://web.whatsapp.com/send?phone=#{ pn }&text=#{ ERB::Util.url_encode msg }"
  end

  def update_transactions
    checkout_transactions = CheckoutTransaction.where('DATE(checkout_transactions.created_at) = DATE(?) AND payment_method = \'Gepind\'', params[:start_date]).order(created_at: :desc)
    data = checkout_transactions.map { |x| { member_id: x.checkout_balance.member.id, name: x.checkout_balance.member.name, price: x.price, date: x.created_at.to_date } }

    render :json => data
  end

  def get_payments
    payments = if params[:start_date].blank?
                 Payment.where(updated_at: 1.weeks.ago..1.days.from_now, payment_type: [:payconiq_online, :payconiq_display], status: 'SUCCEEDED')
               else
                 Payment.where(updated_at: Date.strptime(params[:start_date], "%Y-%m-%d")..Date.strptime(params[:end_date], "%Y-%m-%d"), payment_type: [:payconiq_online, :payconiq_display], status: 'SUCCEEDED')

               end
    activitysum = Hash.new {|h,k| h[k] = Hash.new(&h.default_proc) }
    payments.where(:transaction_type => :activity).map do |payment|
      payment.transaction_id.each do |activity_id|
        p = Participant.where(member: payment.member, activity_id: activity_id).first
        activitysum[payment.member.id][p.activity.name][:price]= "#{p.currency}"

        if p.activity.group.nil?
          activitysum[payment.member.id][p.activity.name][:ledgernr] = Group.first.ledgernr
          activitysum[payment.member.id][p.activity.name][:cost_location] = Group.first.cost_location
        else
          activitysum[payment.member.id][p.activity.name][:ledgernr] = p.activity.group.ledgernr
          activitysum[payment.member.id][p.activity.name][:cost_location] = p.activity.group.cost_location
        end
        activitysum[payment.member.id][p.activity.name][:VAT] = p.activity.VAT

      end
    end
    mongoose_payments = payments.where(:transaction_type => :checkout).group(:member_id).sum(:amount)
    return { total: payments.sum(:amount), exact: {activiteiten:activitysum, mongoose:mongoose_payments}, online: payments.payconiq_online.count, display: payments.payconiq_display.count }
  end


end
