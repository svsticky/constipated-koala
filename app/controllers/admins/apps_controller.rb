class Admins::AppsController < ApplicationController

  def checkout
    
  end
  
  def ideal
    
  end

  def radio 
    @advert = Advertisement.new
    @advertisements = Advertisement.all
  end
  
  def advertisement
    @advert = Advertisement.new(advertisement_post_params)   
    
    if @advert.save
      redirect_to apps_radio_path
    else
      @advertisements = Advertisement.all
      render 'radio'
    end
  end
  
  def studystatus
    
  end
  
  private
  def advertisement_post_params
    params.require(:advertisement).permit(  :name,
                                            :poster)
  end
end