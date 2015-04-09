class Admins::AppsController < ApplicationController

  def ideal
    @transactions = IdealTransaction.all
  end
  
  def studystatus
    
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
  
  def destroy     
    if params[:id].blank?
      render :status => :bad_request, :json => 'no id given'
    end
      
    advert = Advertisement.find(params[:id])
    advert.destroy
    
    render :status => :no_content, :json => ''
  end
  
  private
  def advertisement_post_params
    params.require(:advertisement).permit(  :name,
                                            :poster)
  end
end
