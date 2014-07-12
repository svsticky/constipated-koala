class HomeController < ApplicationController
  def index
    #TODO optimize sql query to count
    @members = Education.group('member_id').where('end_date IS NULL').length
    
    @activities = Activity.count(:all)
    
    #TODO mongoose implementatie
    @sales = 0
    
    #TODO unpayed activities (+ mongoose?)
    @unpayed = Participant.where(:paid => false).sum(:price)# + Participant.where(:paid => false, :price => nil).select(:activity).sum(price)
  end
end
