class Admins::SettingsController < ApplicationController
  respond_to :json, only: [:create, :destroy]

  def index
    @studies = Study.all

    @advert = Advertisement.new
    @advertisements = Advertisement.all
  end

  def create
    if ['additional_moot_positions', 'additional_committee_positions'].include? params[:setting]
      Settings[params[:setting]] = params[:value].split(',')
    elsif ['intro_membership','intro_activities'].include? params[:setting]
      Settings[params[:setting]] = params[:value].split(',').map(&:to_i)
    elsif ['mongoose_ideal_costs'].include? params[:setting]
      Settings[params[:setting]] = params[:value].to_f
    elsif ['begin_study_year'].include? params[:setting]
      Settings[params[:setting]] = Date.parse(params[:value])
    else
      Settings[params[:setting]] = params[:value]
    end

    render :status => :ok, :json => nil
    return
  end

  def logs
    @limit = params[:limit] ? params[:limit].to_i : 50
    @offset = params[:offset] ? params[:offset].to_i : 0

    @impressions = Impression.all.order( created_at: :desc ).limit(@limit).offset(@offset)

    @page = @offset / @limit
    @pages = (Impression.count / @limit.to_i).ceil
  end

  def advertisement
    @advert = Advertisement.new(advertisement_post_params)

    if @advert.save
      redirect_to settings_path
    else
      @settings = UserConfiguration.all

      @studies = Study.all

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
