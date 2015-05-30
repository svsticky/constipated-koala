class Admins::AppsController < ApplicationController

  def ideal
    @transactions = IdealTransaction.all
  end
  
  def studystatus
    
  end
  
  private
  def advertisement_post_params
    params.require(:advertisement).permit(  :name,
                                            :poster)
  end
end
