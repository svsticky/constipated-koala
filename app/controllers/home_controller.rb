class HomeController < ApplicationController
  def index
    #TODO optimize sql query to count
    @members = Education.group('member_id').where('status = 0').length
    
    @activities = Activity.count(:all)
    
    #TODO mongoose implementatie
    @sales = 0
    
    #TODO unpayed activities (+ mongoose?)
    @unpayed = Participant.where(:paid => false).sum(:price) + Participant.where(:paid => false, :price => NIL).joins(:activity).where('activities.price IS NOT NULL').sum('activities.price')
  end
end
