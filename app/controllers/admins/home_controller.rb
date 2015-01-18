class Admins::HomeController < ApplicationController
  def index
    @members = Education.group('member_id').where('status = 0').length
#    @alumnus = Education.group('member_id').where('status = 2').length
    
    @activities = Activity.where("start_date >= ?", Date.start_studyyear).count
#    @participants = Participant.distinct.count(:member_id)
    
    @transactions = CheckoutTransaction.count(:all)
#    @credit = CheckoutBalance.sum(:balance)
    
    #TODO unpayed activities (+ mongoose?)
    @unpayed = Participant.where(:paid => false).sum(:price) + Participant.where(:paid => false, :price => NIL).joins(:activity).where('activities.price IS NOT NULL').sum('activities.price')
    
    @studies = Education.where('status = 0').joins('study').group('study').count
    
    @defaulters = Participant.where(:paid => false).group('member').sum(:price).merge(Participant.where(:paid => false, :price => nil).joins(:activity) \
      .group('member').sum('activities.price')){ |k, sum_a, sum_b| sum_a + sum_b }.sort_by(&:last).reverse!.take(10)
    
    @birthdates = Hash[Member.find(1) => 12]
  end
end
