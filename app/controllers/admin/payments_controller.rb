#:nodoc:
class Admin::PaymentsController < ApplicationController
  def index
    @detailed = Activity.debtors.sort_by(&:start_date).reverse!
    @last_impressions = Activity.debtors.map do |activity|
      impression = Impression.where(impressionable_type: Activity).where(impressionable_id: activity.id).where(message: "mail").where('created_at > ?', activity.start).last

      days = if impression
               Integer(Date.today - impression.created_at.to_date)
             else
               "-"
             end
      [activity, days]
    end

    # Get checkout transactions that were purchased by pin of yesterday
    @checkout_transactions = CheckoutTransaction.where('DATE(checkout_transactions.created_at) = DATE(?) AND payment_method = "Gepind"', 1.days.ago).order(created_at: :desc)
    @dat = @checkout_transactions.map { |x| { member_id: x.checkout_balance.member.id, name: x.checkout_balance.member.name, price: x.price, date: x.created_at.to_date } }.to_json
    # Get members of which the activities have been mailed 4 times, but haven't paid yet
    @late_activities = Activity.debtors.select { |activity| activity.impressionist_count(message: "mail", start_date: activity.start) >= 4 && activity.ended? }
    @late_payments =
      @late_activities.map do |activity|
        activity.attendees.select do |participant|
          participant.paid == false &&
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
    checkout_transactions = CheckoutTransaction.where('DATE(checkout_transactions.created_at) = DATE(?) AND payment_method = "Gepind"', params[:start_date]).order(created_at: :desc)
    data = checkout_transactions.map { |x| { member_id: x.checkout_balance.member.id, name: x.checkout_balance.member.name, price: x.price, date: x.created_at.to_date } }

    render :json => data
  end


end
