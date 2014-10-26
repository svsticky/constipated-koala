class HomeController < ApplicationController
  def index
    #TODO optimize sql query to count
    @members = Education.group('member_id').where('end_date IS NULL').length
    @alumni = 0
    
    @activities = Activity.count(:all)
    @participants = Participant.count(:all)
    
    #TODO mongoose implementatie
    @transactions = CheckoutTransaction.count(:all)
    @credit = CheckoutBalance.sum(:balance)
    
    #TODO unpayed activities (+ mongoose?)
    @unpayed = Participant.where(:paid => false).sum(:price) + Participant.where(:paid => false, :price => NIL).joins(:activity).where('activities.price IS NOT NULL').sum('activities.price')
  end
end
