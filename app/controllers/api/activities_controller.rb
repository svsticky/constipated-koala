class Api::ActivitiesController < ApiController
  before_action -> { doorkeeper_authorize! 'activity-read' }, only: :show

  def index
    respond_with Activity.all.order(:end_date, :start_date).limit(params[:limit] ||= 10).offset(params[:offset] ||= 0).select(:id, :name, :start_date, :end_date, :poster_updated_at).map{ |item| (item.attributes.merge({ :poster => Activity.find(item.id).poster.url(:medium) }) unless item.poster_updated_at.nil?)}.compact and return if params[:date].nil?

    respond_with Activity.where('(end_date IS NULL AND start_date >= ?) OR end_date >= ?', params[:date], params[:date] ).limit(params[:limit] ||= 10).offset(params[:offset] ||= 0).select(:id, :name, :start_date, :end_date, :poster_updated_at).map{ |item| (item.attributes.merge({ :poster => Activity.find(item.id).poster.url(:medium) }) unless item.poster_updated_at.nil?)}.compact
  end

  def show
    respond_with Activity.find_by_id!(params[:id]), { :include => :participants }
  end

  def adverts
    respond_with Advertisement.all.select(:id, :poster_updated_at).map{ |item| (item.attributes.merge({ :poster => Advertisement.find(item.id).poster.url(:original) }) if !item.poster_updated_at.nil?)}
  end

end
