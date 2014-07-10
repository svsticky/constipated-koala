class HomeController < ApplicationController
  def index
    #TODO optimize sql query to count
    @members = Education.group('member_id').where('end_date IS NULL').length
    
    #TODO count activites table
    @activities = Activity.count(:all)
    
    #TODO mongoose implementatie
    @sales = 0
    
    #TODO unpayed activities (+ mongoose?)
    @unpayed = '0,00'
  end
end
