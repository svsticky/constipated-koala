# Internal API controller
class Api::InternalController < ActionController::Base
  protect_from_forgery except: %i[mongoose_user]
  before_action :authenticate_internal, only: %i[mongoose_user]

  respond_to :json

  def member_by_studentid
    @mongoose_user = Member.select(:id, :first_name, :infix, :last_name, :birth_date,
                                   :email).find_by(student_id: params[:student_number])
    return head(:no_content) unless @mongoose_user
  end

  def member_by_id
    @mongoose_user = Member.select(:id, :first_name, :infix, :last_name,
                                   :birth_date).find(params[:id])
    return head(:no_content) unless @mongoose_user
  end

  def authenticate_internal
    return unless request.headers['Authorization'] != ENV['CHECKOUT_TOKEN']

    head(:forbidden)
    nil
  end

  def authenticate_card
    @uuid = params[:uuid]
    @card = CheckoutCard.find_by(uuid: @uuid)
    render(status: :not_found && return) if @card.nil?
    render(status: :unauthorized, json: I18n.t('checkout.error.not_activated')) unless @card.active
    render(status: :unauthorized, json: I18n.t('checkout.error.disabled')) if @card.disabled
    (@card.active and !@card.disabled)
  end
end
