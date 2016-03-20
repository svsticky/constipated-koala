class Admin::SettingsController < ApplicationController
  respond_to :json, only: [:create, :destroy]

  def index
    @studies = Study.all

    @applications = Doorkeeper::Application.all

    @advert = Advertisement.new
    @advertisements = Advertisement.all
  end

  def create
    if ['additional_moot_positions', 'additional_committee_positions'].include? params[:setting]
      Settings[params[:setting]] = params[:value].downcase.split(',')
    elsif ['intro_membership','intro_activities'].include? params[:setting]
      Settings[params[:setting]] = Activity.where( id: params[:value].split(',').map(&:to_i) ).collect(&:id)
      render :status => :ok, :json => {
        activities: Settings[params[:setting]],
        warning: params[:value].split(',').map(&:to_i).count != Settings[params[:setting]].count
      }
      return #check if activities exists
    elsif ['mongoose_ideal_costs'].include? params[:setting]
      render :status => :bad_request and return if (params[:value] =~ /\d{1,}[,.]\d{2}/).nil?
      Settings[params[:setting]] = params[:value].sub(',','.').to_f
    elsif ['begin_study_year'].include? params[:setting]
      render :status => :bad_request and return if (params[:value] =~ /\d{4}\-\d{2}\-\d{2}/).nil?
      Settings[params[:setting]] = Date.parse(params[:value])
    elsif ['liquor_time'].include? params[:setting]
      render :status => :bad_request and return if (params[:value] =~ /\d{2}\:\d{2}/).nil?
      Settings[params[:setting]] = params[:value]
    end

    render :status => :ok, :json => ''
    return
  end

  def advertisement
    @advert = Advertisement.new(advertisement_post_params)

    if @advert.save
      redirect_to settings_path
    else
      @studies = Study.all

      @clients = Doorkeeper::Application.all

      @advert = Advertisement.new
      @advertisements = Advertisement.all

      render 'index'
    end
  end

  def destroy_advertisement
    if params[:id].blank?
      render :status => :bad_request, :json => 'no id given'
    end

    Advertisement.destroy(params[:id])
    render :status => :no_content, :json => ''
  end

  def logs
    @limit = params[:limit] ? params[:limit].to_i : 50
    @offset = params[:offset] ? params[:offset].to_i : 0

    @impressions = Impression.all.order( created_at: :desc ).limit(@limit).offset(@offset)

    @page = @offset / @limit
    @pages = (Impression.count / @limit.to_i).ceil
  end

  private
  def advertisement_post_params
    params.require(:advertisement).permit(:name, :poster)
  end
end
