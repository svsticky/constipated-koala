class HomeController < ApplicationController
  def index
    @members = Education.group('member_id').where('end_date IS NULL').length
    @activities = 0
    @sales = 0
    @unpayed = '0,00'
  end
end
