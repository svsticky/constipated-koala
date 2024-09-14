#:nodoc:
class Admin::LogsController < ApplicationController
  def index
    @limit = params[:limit] ? params[:limit].to_i : 50

    @pagination, @impressions = pagy(Impression.all.order(created_at: :desc),
                                     items: params[:limit] ||= 50)
    @total_log_items = Impression.count
  end
end
