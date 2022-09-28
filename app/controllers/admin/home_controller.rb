#:nodoc:
class Admin::HomeController < ApplicationController
  def index
    @members = Member.active.count

    @studies = Education.where('status = 0').joins(:study).group('studies.code').count

    @activities = Activity.where("start_date >= ?", Date.to_date(Time.zone.today.study_year)).count

    @transactions = CheckoutTransaction.count(:all)

    @recent = CheckoutTransaction.where(
      "created_at >= ?",
      Time.zone.now.beginning_of_day
    ).order(created_at: :desc).take(12)

    @recentactivities = Payment.where(
      "created_at >= ?",
      Time.zone.now.beginning_of_day
    ).where(
      transaction_type: :activity,
      status: :successful
    ).take(12)

    @unpaid = Member.debtors.map(&:total_outstanding_payments).sum

    @defaulters = Member.debtors.sort_by { |debtor| -debtor.total_outstanding_payments }.take(12)
  end
end
