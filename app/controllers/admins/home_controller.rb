class Admins::HomeController < ApplicationController
  def index
    @members = Education.group('member_id').where('status = 0').length
    @studies = Education.where('status = 0').joins(:study).group('studies.name').order('studies.masters').count
    logger.debug @studies
    
    @activities = Activity.where("start_date >= ?", Date.start_studyyear( Date.current().year )).count
    
    @transactions = CheckoutTransaction.count(:all)
    
    @unpayed = Participant.where(:paid => false).sum(:price) + Participant.where(:paid => false, :price => NIL).joins(:activity).where('activities.price IS NOT NULL').sum('activities.price')
    @defaulters = Participant.where(:paid => false).joins(:activity).where('activities.start_date < NOW()').group('member').sum(:price).merge( \
      Participant.where(:paid => false, :price => nil).joins(:activity).where('activities.start_date < NOW()') \
      .group('member').sum('activities.price') ){ |k, sum_a, sum_b| sum_a + sum_b }.sort_by(&:last).reverse!.take(10)
  end
end
