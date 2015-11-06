class Api::CheckoutController < ApiController
  before_action -> { doorkeeper_authorize! 'checkout-read' }, only: [:index, :info]
  before_action -> { doorkeeper_authorize! 'checkout-write' }, only: [:update, :destroy]

  before_action :authenticate_checkout, only: [:show, :create, :transaction, :products]

  def index
    @transactions = CheckoutTransaction.where( :checkout_balance => CheckoutBalance.find_by_member( current_user.credentials ) ).order( created_at: :desc ).limit( params[:limit] ||= 50 ).offset( params[:offset] ||= 0 )
  end

  def transaction
    card = CheckoutCard.find_by_uuid!( params[:uuid] )

    render :status => :unauthorized, :json => 'card not yet activated' and return unless card.active
    transaction = CheckoutTransaction.new( :items => params[:items].to_a, :checkout_card => card )

    begin
      transaction.save
    rescue ActiveRecord::RecordNotSaved => error
      render :status => :not_acceptable, :json => error.message if error.message == 'not_allowed'
      render :status => :bad_request, :json => error.message if error.message == 'empty_items'
      render :status => :request_entity_too_large, :json => error.message if error.message == 'insufficient_funds'
      return
    end

    respond_with transaction
  end

  def ideal
    #TODO implement
  end

  def products
    @products = CheckoutProduct.where( :active => true ).select( :id, :name, :category, :price )
  end

  def info
    @balance = CheckoutBalance.where( :member => current_user.credentials )
  end

  def create
    render :status => :conflict, :json => 'card already registered' and return unless CheckoutCard.find_by_uuid( params[:uuid] ).nil?

    card = CheckoutCard.new( :uuid => params[:uuid], :member => Member.find_by_student_id!( params[:student] ), :description => params[:description] )

    card.save
    respond_with card
  end

  def show #TODO add boolean for older than 18, birth_date is not necessary
    respond_with CheckoutCard.joins( :member, :checkout_balance ).select( :id, :uuid, :first_name, :balance ).find_by_uuid!( params[:uuid] )
  end

  def update
    card = CheckoutCard.find_by_uuid!( params[:uuid] )
    card.update_attribute( :active, true )

    card.save
    respond_with card
  end

  def destroy
    card = CheckoutCard.find_by_uuid!( params[:uuid] )
    respond_with card.destroy
  end

  private #TODO change to OAuth client_credentials
  def authenticate_checkout
    if params[:token] != ENV['CHECKOUT_TOKEN']
      render :status => :forbidden, :json => 'not authenticated'
      return
    end
  end
end
