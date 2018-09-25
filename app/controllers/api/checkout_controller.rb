# Controller used for checkout before oauth was implemented
# @deprecated controller, base controller should be replaced with oauth
class Api::CheckoutController < ActionController::Base
  protect_from_forgery except: %i[info purchase create products]
  before_action :authenticate_checkout, only: %i[info purchase create products]

  respond_to :json

  def products
    @products = CheckoutProduct.where(active: true)
  end

  def info
    @card = CheckoutCard.joins(:member, :checkout_balance).select(:id, :uuid, :first_name, :balance).find_by(uuid: params[:uuid])
    head :not_found unless @card
  end

  def purchase
    card = CheckoutCard.find_by_uuid!(params[:uuid])

    unless card.active
      render status: :unauthorized, json: 'card not yet activated'
      return
    end

    transaction = CheckoutTransaction.new(items: ahelper(params[:items]), checkout_card: card)

    if transaction.save!
      render status: :created, json: {
        uuid:       card.uuid,
        first_name: card.member.first_name,
        balance:    card.checkout_balance.balance,
        created_at: transaction.created_at
      }
    else
      i18n_scope = %i[activerecord errors models checkout_transaction attributes]

      not_liquor_time_translation = I18n.t('items.not_liquor_time', scope: i18n_scope)
      insufficient_credit_translation = I18n.t('price.insufficient_credit', scope: i18n_scope)

      case transaction.errors
      when transaction.errors[:items].includes(not_liquor_time_translation)
        render status: :not_acceptable, json: {
          message: not_liquor_time_translation
        }
      when transaction.errors[:price].includes(insufficient_credit_translation)
        render status: :payload_too_large, json: {
          message: I18n.t(insufficient_credit_translation, scope: i18n_scope),
          balance: card.checkout_balance.balance,
          items:   ahelper(params[:items]),
          costs:   transaction.price
        }
      else
        render status: :bad_request, json: {
          errors: transaction.errors
        }
      end
    end
  end

  def create
    head(:conflict) && return unless CheckoutCard.find_by_uuid(params[:uuid]).nil?

    card = CheckoutCard.new(uuid: params[:uuid], member: Member.find_by_student_id!(params[:student]), description: params[:description])

    if card.save
      card.send_confirmation!
      render status: :created, json: CheckoutCard.joins(:member, :checkout_balance).select(:id, :uuid, :first_name, :balance).find_by_uuid!(params[:uuid]).to_json
    else
      head :conflict
    end
  end

  def confirm
    card = CheckoutCard.where(['confirmation_token = ?', params['confirmation_token']]).first
    redirect_to :new_user_session

    if card.nil?
      flash[:alert] = 'Bevestigingstoken is ongeldig!'
      return
    end

    if card.active
      flash[:alert] = 'Kaart is al geactiveerd!'
      return
    end

    if card.update(active: true)
      flash[:notice] = 'Kaart geactiveerd!'
    else
      flash[:alert] = 'Kaart kon niet worden geactiveerd!'
    end
  end

  private

  def ahelper(obj)
    return [] if obj.empty?

    begin
      return Array.new(1, obj.to_i) if obj.is_number?

      return JSON.parse(obj)
    rescue StandardError
      return []
    end
  end

  # TODO: implement for OAuth client credentials
  def authenticate_checkout
    if params[:token] != ENV['CHECKOUT_TOKEN']
      head :forbidden
      nil
    end
  end
end
