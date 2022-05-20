#:nodoc:
class Admin::HomeController < ApplicationController
  def index
    @members = Education.where('status = 0').distinct.count(:member_id) + Tag.joins(:member, member: :educations).where('status != 0').distinct.count(:member_id)
    @studies = Education.where('status = 0').joins(:study).group('studies.code').count

    @activities = Activity.where("start_date >= ?", Date.to_date(Date.today.study_year)).count

    @transactions = CheckoutTransaction.count(:all)

    @recent = CheckoutTransaction.where("created_at >= ?", Time.zone.now.beginning_of_day).order(created_at: :desc).take(12)
    @recentactivities = Payment.where("created_at >= ?", Time.zone.now.beginning_of_day).where(transaction_type: :activity, status: :successful).take(12)

    @unpayed = Participant.where(reservist: false, paid: false).joins(:activity).where('activities.start_date < NOW()').sum(:price) + Participant.where(reservist: false, paid: false, price: nil).joins(:activity).where('activities.start_date < NOW() AND activities.price IS NOT NULL').sum('activities.price')

    @defaulters = Member.debtors.sort_by { |debtor| -debtor.total_outstanding_payments }.take(12)
  end
end
