class Admins::SettingsController < ApplicationController
  respond_to :json, only: [:destroy]

  def index 
    @settings = UserConfiguration.all
    
    @studies = Study.all
    
    @advert = Advertisement.new
    @advertisements = Advertisement.all
  end
  
  def advertisement
    @advert = Advertisement.new(advertisement_post_params)   
    
    if @advert.save
      redirect_to settings_path
    else
      @settings = UserConfiguration.all

      @advertisements = Advertisement.all
      render 'index'
    end
  end
  
  def destroy_advertisement
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
