#:nodoc:
class Admin::SettingsController < ApplicationController
  respond_to :json, only: [:create, :destroy]

  def index
    @admin = current_user.credentials
    @user = User.find_by(email: current_user.email)

    @studies = Study.all

    @applications = Doorkeeper::Application.all
  end

  def create
    if ['additional_positions.moot', 'additional_positions.committee'].include? params[:setting]
      Settings[params[:setting]] = params[:value].downcase.split(',').each(&:strip!)

    elsif ['intro.membership', 'intro.activities'].include? params[:setting]
      Settings[params[:setting]] = Activity.where(id: params[:value].split(',').map(&:to_i)).collect(&:id)

      render status: :ok, json: {
        activities: Settings[params[:setting]],
        warning: params[:value].split(',').map(&:to_i).count != Settings[params[:setting]].count
      }
      return
    elsif %w[mongoose_ideal_costs].include? params[:setting]
      head(:bad_request) && return if (params[:value] =~ /\d{1,}[,.]\d{2}/).nil?

      Settings[params[:setting]] = params[:value].sub(',', '.').to_f
    elsif ['begin_study_year'].include? params[:setting]
      head(:bad_request) && return if (params[:value] =~ /\d{4}-\d{2}-\d{2}/).nil?

      Settings[params[:setting]] = Date.parse(params[:value])
    elsif ['liquor_time'].include? params[:setting]
      head(:bad_request) && return if (params[:value] =~ /\d{2}:\d{2}/).nil?

      Settings[params[:setting]] = params[:value]
    elsif %w[ideal_relation_code payment_condition_code mongoose_ledger_number accountancy_ledger_number].include? params[:setting]
      head(:bad_request) && return if (params[:value] =~ /\d+/).nil?

      Settings[params[:setting]] = params[:value]
    elsif ['accountancy_cost_location'].include? params[:setting]
      Settings[params[:setting]] = params[:value]
    end
    head :ok
    return
  end

  def profile
    @user = User.find_by(email: current_user.email)
    @user.update(user_post_params)

    @admin = Admin.find(current_user.credentials_id)
    @admin.update(admin_post_params)

    return redirect_to users_root_path(l: @user.language)
  end

  def logs
    @limit = params[:limit] ? params[:limit].to_i : 50

    @pagination, @impressions = pagy(Impression.all.order(created_at: :desc), items: params[:limit] ||= 50)
    @total_log_items = Impression.count
  end

  private

  def admin_post_params
    params.require(:admin).permit(:first_name, :infix, :last_name, :signature, :avatar)
  end

  def user_post_params
    params.require(:admin).permit(:language)
  end
end
