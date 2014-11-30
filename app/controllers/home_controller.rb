class HomeController < ApplicationController
  def index
    @members = Education.group('member_id').where('status = 0').length
    @alumnus = 0
    
    @activities = Activity.count(:all)
    
    #TODO mongoose implementatie
    @sales = 0
    @credit = 0
    
    #TODO unpayed activities (+ mongoose?)
    @unpayed = Participant.where(:paid => false).sum(:price) + Participant.where(:paid => false, :price => NIL).joins(:activity).where('activities.price IS NOT NULL').sum('activities.price')
    @mongoose = 0
    
    @studies = Education.joins('study').group('study').count
    
    @birthdates = 0

  end
end
