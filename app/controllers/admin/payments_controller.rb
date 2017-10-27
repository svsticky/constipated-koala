class Admin::PaymentsController < ApplicationController
  def index
    @detailed = Activity.debtors.sort_by(&:start_date).reverse!
    @last_impressions = Activity.debtors.map { |activity|
      impression = Impression.where(impressionable_type: Activity).where(impressionable_id: activity.id).where(message: "mail").where('created_at > ?', activity.start).last

      if impression
        days = Integer(Date.today - impression.created_at.to_date)
      else
        days = "-"
      end
      [activity, days]
    }

    # Get checkout transactions that were purchased by pin of yesterday
    @checkout_transactions = CheckoutTransaction.where('DATE(checkout_transactions.created_at) = DATE(?) AND payment_method = "Gepind"', 1.days.ago).order(created_at: :desc)
    @dat = @checkout_transactions.map { |x| { member_id: x.checkout_balance.member.id, name: x.checkout_balance.member.name, price: x.price, date: x.created_at.to_date } }.to_json

    # Get members of which the activities have been mailed 4 times, but haven't paid yet
    @late_activities = Activity.debtors.select { |activity| activity.impressionist_count(message: "mail", start_date: activity.start) >= 4 }
    @late_payments =
      @late_activities.map { |activity|
      activity.participants.select { |participant|
        participant.paid == false &&
          participant.price != 0 &&
          participant.reservist == false
      }.map { |p| p.member }
    }.flatten.uniq
  end

  def update_transactions
    checkout_transactions = CheckoutTransaction.where('DATE(checkout_transactions.created_at) = DATE(?) AND payment_method = "Gepind"', params[:start_date]).order(created_at: :desc)
    data = checkout_transactions.map { |x| { member_id: x.checkout_balance.member.id, name: x.checkout_balance.member.name, price: x.price, date: x.created_at.to_date } }

    respond_to do |format|
      format.js { render :json => data.to_json }
    end
  end
end
