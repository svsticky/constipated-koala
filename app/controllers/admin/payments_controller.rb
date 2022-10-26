#:nodoc:
class Admin::PaymentsController < ApplicationController
  require 'csv'
  require 'active_support'
  def index
    @detailed = Activity.debtors.sort_by(&:start_date).reverse!
    @last_impressions = Activity.debtors.map do |activity|
      if activity.payable_updated_at > Date.today.prev_occurring(:friday)
        days = -1
        sent_mails = 0
      else
        days_passed = (Date.today.prev_occurring(:friday) - activity.payable_updated_at).to_i
        days = (Date.today - Date.today.prev_occurring(:friday)).to_i
        sent_mails = (days_passed / 7).floor + 1
      end
      [activity, days, sent_mails]
    end

    # Get checkout transactions that were purchased by pin of yesterday
    @checkout_transactions = CheckoutTransaction.where(
      'DATE(checkout_transactions.created_at) = DATE(?) AND payment_method = \'Gepind\'', 1.day.ago
    ).order(created_at: :desc)
    @dat = @checkout_transactions.map do |x|
      { member_id: x.checkout_balance.member.id, name: x.checkout_balance.member.name, price: x.price,
        date: x.created_at.to_date }
    end.to_json

    # Counts if the activity has debtors and if 4 weeks have passed (last friday
    # is more than 21 days ago since 0 counts aswell)
    @late_activities = Activity.debtors.select do |activity|
      (Date.today.prev_occurring(:friday) - activity.payable_updated_at).to_i >= 21 && activity.is_payable
    end
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
    @late_unpayable_activities = Activity.late_unpayable
  end

  def whatsapp_redirect
    @member = Member.find(params[:member_id])
    @activities = @member.unpaid_activities.where('activities.start_date <= ?', Date.today).distinct
    @participants = @activities.map { |a| Participant.find_by(member: @member, activity: a) }
    msg = render_to_string(template: 'admin/members/payment_whatsapp.html.haml', layout: false,
                           content_type: "text/plain")

    pn = @member.phone_number

    redirect_to("https://web.whatsapp.com/send?phone=#{ pn }&text=#{ ERB::Util.url_encode(msg) }")
  end

  def update_transactions
    checkout_transactions = CheckoutTransaction.where(
      'DATE(checkout_transactions.created_at) = DATE(?) AND payment_method = \'Gepind\'', params[:start_date]
    ).order(created_at: :desc)
    data = checkout_transactions.map do |x|
      { member_id: x.checkout_balance.member.id, name: x.checkout_balance.member.name, price: x.price,
        date: x.created_at.to_date }
    end

    render(json: data)
  end

  def export_payments
    unless params[:export_type].present? && params[:start_date].present? && params[:end_date].present?
      return head(:bad_request)
    end

    payment_type = :ideal

    @transaction_file = CSV.generate do |input|
      @payments = Payment.where(
        created_at: (Date.strptime(params[:start_date], "%Y-%m-%d")..Date.strptime(params[:end_date], "%Y-%m-%d")),
        payment_type: payment_type,
        status: :successful
      )
      create_invoice(input, @payments, payment_type, params[:start_date], params[:end_date])
    end

    respond_to do |format|
      format.html { redirect_to(payments_path) }
      format.csv do
        send_data(@transaction_file,
                  filename: "payments_#{ Date.strptime(params[:start_date],
                                                       '%Y-%m-%d') }_#{ Date.strptime(params[:end_date],
                                                                                      '%Y-%m-%d') }.csv")
      end
      format.js do
        render(js: "window.open(\"#{ transactions_export_path(
          format: :csv,
          start_date: params[:start_date],
          end_date: params[:end_date],
          payment_type: payment_type,
          export_type: params[:export_type]
        ) }\", \"_blank\")")
      end
    end
  end

  private

  def create_invoice(csv, payments, payment_type, start_date, end_date = nil)
    return if payments.empty?

    # Initial row of data for every invoice, Billing date, invoice description, Payment code, relationnumber.
    description = "#{ payment_type } - #{ if end_date.nil?
                                            Date.strptime(start_date,
                                                          '%Y-%m-%d')
                                          else
                                            "#{ Date.strptime(start_date,
                                                              '%Y-%m-%d') } / #{ Date.strptime(
                                                                end_date, '%Y-%m-%d'
                                                              ) }"
                                          end }"
    relation_code = Settings.ideal_relation_code
    csv << ["Factuurdatum", Date.today, description, Settings.payment_condition_code.to_s,
            relation_code]

    payments.where(transaction_type: :activity).each do |payment|
      payment.transaction_id.each do |activity_id|
        p = Participant.where(member: payment.member, activity_id: activity_id).first
        # now create every transaction row with the following date: Blank, ledger account,
        # transaction description, VAT number, amount, cost_location ()
        a = Activity.find_by(id: activity_id)
        csv << if a && a.name == "Lidmaatschap"
                 # Dislike this way of doing it but need better ways to find membership activities
                 # An alternative could be activity_id == Settings['intro.membership'],
                 # this would make it only pass for last year membership activity
                 ["", "8000", "#{ p.activity.name } - #{ p.member_id }", '0',
                  p.currency + p.transaction_fee, ""]
               elsif p.activity.group.nil? ||
                     (!p.activity.group.nil? && p.activity.group.ledgernr.blank?)
                 ["", "1302", "#{ p.activity.name } - #{ p.member_id }", p.activity.VAT,
                  p.currency, ""]
               else
                 ["", p.activity.group.ledgernr, "#{ p.activity.name } - #{ p.member_id }",
                  p.activity.VAT, p.currency, p.activity.group.cost_location]
               end
      end
    end

    payments.where(transaction_type: :checkout).each do |payment|
      # Add all mongoose charge ups
      csv << ["", Settings.mongoose_ledger_number, "Mongoose - #{ payment.member_id }", "9",
              payment.amount - Settings.mongoose_ideal_costs, ""]
    end
    # minus lidmaatschap payments
    activity_amount = payments.where(transaction_type: :activity).count - payments.where(
      transaction_type: :activity,
      transaction_id: Settings['intro.membership']
    ).count
    # TODO: should probably be backwards compatible but we don't log all membership activities

    mongoose_amount = payments.where(transaction_type: :checkout).count
    trx_cost = "Transaction costs #{ Settings.mongoose_ideal_costs } x #{ activity_amount }"
    trx_cost_amount = (Settings.mongoose_ideal_costs * activity_amount).round(2)
    trx_mongoose_cost = "Transaction costs mongoose #{ Settings.mongoose_ideal_costs } x #{ mongoose_amount }"
    trx_mongoose_amount = (Settings.mongoose_ideal_costs * mongoose_amount).round(2)

    csv << ["", Settings.accountancy_ledger_number, trx_cost, "21",
            trx_cost_amount, Settings.accountancy_cost_location]
    csv << ["", Settings.accountancy_ledger_number, trx_mongoose_cost, "21",
            trx_mongoose_amount, Settings.accountancy_cost_location]
  end
end
