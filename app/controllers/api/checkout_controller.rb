class Api::CheckoutController < ApplicationController
  protect_from_forgery except: %i[info purchase create products]

  skip_before_action :authenticate_user!, only: %i[info purchase create products confirm]
  skip_before_action :authenticate_admin!, only: %i[info purchase create products confirm]

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
      sendConfirmation(card)
      render status: :created, json: CheckoutCard.joins(:member, :checkout_balance).select(:id, :uuid, :first_name, :balance).find_by_uuid!(params[:uuid]).to_json
    else
      head :conflict
    end
  end

  def sendConfirmation(card)
    # Generate token
    digest = OpenSSL::Digest.new('sha1')
    token  = OpenSSL::HMAC.hexdigest(digest, ENV['CHECKOUT_TOKEN'], card.uuid)

    # Save token to card & mail confirmation link
    card.confirmation_token = token
    if card.save
      Mailings::Checkout.confirmation_instructions(card, confirmation_url(confirmation_token: token)).deliver_now
    end

    nil
  end

  def confirm
    if card = CheckoutCard.where(['confirmation_token = ?', params['confirmation_token']]).first
      if !card.active
        card.active = true
        if card.save
          flash[:notice] = 'Kaart geactiveerd!'

        else
          flash[:alert] = 'Kaart kon niet worden geactiveerd!'
        end
      else
        flash[:alert] = 'Kaart is al geactiveerd!'
      end
    else
      flash[:alert] = 'Bevestigingstoken is ongeldig!'
    end

    redirect_to :new_user_session
  end

  def ahelper(obj)
    return [] if obj.empty?

    begin
      return Array.new(1, obj.to_i) if obj.is_number?
      return JSON.parse(obj)
    rescue
      return []
    end
  end

  private # TODO: implement for OAuth client credentials

  def authenticate_checkout
    if params[:token] != ENV['CHECKOUT_TOKEN']
      head :forbidden
      nil
    end
  end
end
