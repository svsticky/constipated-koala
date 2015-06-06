class Admins::AppsController < ApplicationController

  def ideal
    @transactions = IdealTransaction.all
  end
  
  def studystatus
    
  end
end
