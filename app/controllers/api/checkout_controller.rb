class Api::CheckoutController < ApplicationController
  protect_from_forgery except: [:info, :purchase, :create, :products]

  skip_before_action :authenticate_user!, only: [:info, :purchase, :create, :products]
  skip_before_action :authenticate_admin!, only: [:info, :purchase, :create, :products]

  before_action :authenticate_checkout, only: [:info, :purchase, :create, :products]

  respond_to :json

  def products
    @products = CheckoutProduct.where(:active => true)
  end

  def info
    @card = CheckoutCard.joins(:member, :checkout_balance).select(:id, :uuid, :first_name, :balance).find_by_uuid!(params[:uuid])
  end

  def purchase
    card = CheckoutCard.find_by_uuid!(params[:uuid])

    if( !card.active )
      render :status => :unauthorized, :json => 'card not yet activated'
      return
    end

    transaction = CheckoutTransaction.new( :items => params[:items].to_a, :checkout_card => card )

    begin
      transaction.save
    rescue ActiveRecord::RecordNotSaved => error
      render :status => :not_acceptable, :json => {
        message: "alcohol allowed at #{Settings.liquor_time}"
      } and return if error.message == 'not_allowed'

      head :bad_request and return if error.message == 'empty_items'

      render :status => :request_entity_too_large, :json => {
        message: 'insufficient funds',
        balance: card.checkout_balance.balance,
        items: params[:items].to_a,
        costs: transaction.price
      } if error.message == 'insufficient_funds'
      return
    end

    render :status => :created, :json => {
      uuid: card.uuid,
      first_name: card.member.first_name,
      balance: card.checkout_balance.balance,
      created_at: transaction.created_at
    }
  end

  def create
    head :conflict and return unless CheckoutCard.find_by_uuid(params[:uuid]).nil?

    card = CheckoutCard.new( :uuid => params[:uuid], :member => Member.find_by_student_id!(params[:student]), :description => params[:description] )

    if card.save
      render :status => :created, :json => CheckoutCard.joins(:member, :checkout_balance).select(:id, :uuid, :first_name, :balance).find_by_uuid!(params[:uuid]).to_json
    else
      head :conflict
    end
  end

  def confirm
    if card = CheckoutCard.where(["confirmation_token = ?", params['confirmation_token']]).first
      card.active = true
      if card.save
        #TODO: Render correct
      else
        #TODO: Render wrong: Save failed
    else
      #TODO: Render wrong: Wrong confirmation
    end

    redirect_to public_path
  end

  private # TODO implement for OAuth client credentials
  def authenticate_checkout
    if params[:token] != ENV['CHECKOUT_TOKEN']
      head :forbidden
      return
    end
  end
end
