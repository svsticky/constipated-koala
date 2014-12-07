class HomeController < ApplicationController
  def index
    @members = Education.group('member_id').where('status = 0').length
    @alumnus = Education.group('member_id').where('status = 2').length
    
    @activities = Activity.count(:all)
    @participants = Participant.distinct.count(:member_id)
    
    @transactions = CheckoutTransaction.count(:all)
    @credit = CheckoutBalance.sum(:balance)
    
    #TODO unpayed activities (+ mongoose?)
    @unpayed = Participant.where(:paid => false).sum(:price) + Participant.where(:paid => false, :price => NIL).joins(:activity).where('activities.price IS NOT NULL').sum('activities.price')
    
    @studies = Education.where('status = 0').joins('study').group('study').count
    
    @birthdates = 0
  end
end
