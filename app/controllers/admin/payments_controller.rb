#:nodoc:
require 'csv'
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

  def export_payments
    payments = if params[:start_date].blank?
                 Payment.where(updated_at: 1.weeks.ago..1.days.from_now, payment_type: params[:payment_type] == "Payconiq" ? [:payconiq_online, :payconiq_display] : [:ideal], status: 'SUCCEEDED')
               else
                 Payment.where(updated_at: Date.strptime(params[:start_date], "%Y-%m-%d")..Date.strptime(params[:end_date], "%Y-%m-%d"), payment_type: [:payconiq_online, :payconiq_display], status: 'SUCCEEDED')
               end
     
    @transaction_file = csv_string = CSV.generate do |csv|
      # Initial row of data for every invoice, Billing date, invoice description, Payment code, relationnumber.
      csv << ["Factuurdatum",Date.today, "#{params[:payment_type]} - #{Date.strptime(params[:start_date], "%Y-%m-%d")} / #{Date.strptime(params[:end_date], "%Y-%m-%d")}", ""+Settings.payment_condition_code, (params[:payment_type] == "Payconiq" ? Settings.payconiq_relation_code : Settings.ideal_relation_code)]
      payments.where(:transaction_type => :activity).each do |payment|
        payment.transaction_id.each do |activity_id|
          p = Participant.where(member: payment.member, activity_id: activity_id).first
          # now create every transaction row with the following date: Blank, ledger account, transaction description, VAT number, amount, cost_location ()          

          if p.activity.group.nil?
            csv << ["",Group.first.ledgernr, "#{p.member_id} - #{p.activity.name}", p.activity.VAT, p.currency, Group.first.cost_location]
          else
            csv << ["",p.activity.group.ledgernr, "#{p.member_id} - #{p.activity.name}", p.activity.VAT, p.currency, p.activity.group.cost_location]
          end
        end
      end

      mongoose_payments = payments.where(:transaction_type => :checkout).group(:member_id).sum(:amount).each do |payment|
      # Add all mongoose charge ups
      csv << ["", Settings.mongoose_ledger_number, "Mongoose - #{payment.member_id}", "", payment.amount ,""]
      end
      
    end
    respond_to do |format|
      format.csv {send_data @transaction_file, filename: "payments_#{Date.strptime(params[:start_date], "%Y-%m-%d")}_#{Date.strptime(params[:end_date], "%Y-%m-%d")}.csv"}
      format.js {render :js => "window.open(\"#{transactions_export_path(format: :csv, start_date: params[:start_date], end_date: params[:end_date], payment_type: params[:payment_type])}\", \"_blank\")"}
      end
  end
end
