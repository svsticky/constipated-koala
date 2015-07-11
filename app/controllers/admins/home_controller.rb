class Admins::HomeController < ApplicationController
  def index
    @members = Education.group('member_id').where('status = 0').length
    @studies = Education.where('status = 0').joins(:study).group('studies.name').order('studies.masters, studies.id').count

    @activities = Activity.where("start_date >= ?", Date.start_studyyear( Date.current().year )).count

    @transactions = CheckoutTransaction.count(:all)

    @unpayed = Participant.where(:paid => false).sum(:price) + Participant.where(:paid => false, :price => NIL).joins(:activity).where('activities.price IS NOT NULL').sum('activities.price')

    @defaulters = Participant.where( :paid => false ).joins( :activity, :member ).where('activities.start_date < NOW()').group( :member_id ).sum( :price ).merge( \
      Participant.where( :paid => false ).joins( :activity, :member ).where('activities.start_date < NOW()').group( :member_id ).sum( 'activities.price ')
    ) { |k, sum_a, sum_b| sum_a + sum_b }.sort_by{ |_, sum| -sum }.map{ |k,v| [ Member.where( :id => k).select( :id, :first_name, :infix, :last_name ).first ,v]}.take(15)
  end
end
