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
    respond_with CheckoutCard.joins(:member, :checkout_balance).select(:id, :uuid, :first_name, :balance).find_by_uuid!(params[:uuid])
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

  def change_funds
    if params[:uuid]
      card = CheckoutCard.joins(:checkout_balance).find_by_uuid(params[:uuid])
      transaction = CheckoutTransaction.new( :price => params[:amount], :checkout_card => card )

    elsif params[:member_id]
      transaction = CheckoutTransaction.new( :price => params[:amount], :checkout_balance => CheckoutBalance.find_by_member_id!(params[:member_id]) )

    else
      render :status => :bad_request, :json => ''
      return
    end

    begin
      transaction.save
    rescue ActiveRecord::RecordNotSaved => exception
      render :status => :request_entity_too_large, :json => ''
      return
    rescue ActiveRecord::RecordInvalid
      render :status => :bad_request, :json => ''
      return
    end

    render :status => :created, :json => transaction
  end

  def subtract_funds
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
      } if error.message == 'not_allowed'

      render :status => :bad_request, :json => '' if error.message == 'empty_items'

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

  def add_card_to_member
    if !CheckoutCard.find_by_uuid(params[:uuid]).nil?
      render :status => :conflict, :json => ''
      return
    end

    card = CheckoutCard.new( :uuid => params[:uuid], :member => Member.find_by_student_id!(params[:student]), :description => params[:description] )

    if card.save
      render :status => :created, :json => CheckoutCard.joins(:member, :checkout_balance).select(:id, :uuid, :first_name, :balance).find_by_uuid!(params[:uuid]).to_json
      return
    else
      render :status => :conflict, :json => ''
      return
    end
  end

  def activate_card
    card = CheckoutCard.find_by_uuid!(params[:uuid])

    if params[:_destroy]
      card.destroy

      render :status => :no_content, :json => ''
      return
    end

    card.update_attribute(:active, true)

    if card.save
      render :status => :ok, :json => card.to_json
      return
    else
      render :status => :bad_request, :json => ''
      return
    end
  end

  def products_list
    render :status => :ok, :json => CheckoutProduct.where(:active => true).select(:id, :name, :category, :price).map{ |item| item.attributes.merge({ :image => CheckoutProduct.find_by_id( item.id ).url }) }
  end

  ### TODO master merge
  # def information_for_card
  #   respond_with CheckoutCard.joins(:member, :checkout_balance).select(:id, :uuid, :first_name, :balance).find_by_uuid!(params[:uuid])
  # end
  #
  # def change_funds
  #   if params[:uuid]
  #     card = CheckoutCard.joins(:checkout_balance).find_by_uuid(params[:uuid])
  #     transaction = CheckoutTransaction.new( :price => params[:amount], :checkout_card => card )
  #
  #   elsif params[:member_id]
  #     transaction = CheckoutTransaction.new( :price => params[:amount], :checkout_balance => CheckoutBalance.find_by_member_id!(params[:member_id]) )
  #
  #   else
  #     render :status => :bad_request, :json => ''
  #     return
  #   end
  #
  #   begin
  #     transaction.save
  #   rescue ActiveRecord::RecordNotSaved => exception
  #     render :status => :request_entity_too_large, :json => ''
  #     return
  #   rescue ActiveRecord::RecordInvalid
  #     render :status => :bad_request, :json => ''
  #     return
  #   end
  #
  #   render :status => :created, :json => transaction
  # end
  #
  # def subtract_funds
  #   card = CheckoutCard.find_by_uuid!(params[:uuid])
  #
  #   if( !card.active )
  #     render :status => :unauthorized, :json => 'card not yet activated'
  #     return
  #   end
  #
  #   transaction = CheckoutTransaction.new( :items => params[:items].to_a, :checkout_card => card )
  #
  #   begin
  #     transaction.save
  #   rescue ActiveRecord::RecordNotSaved => error
  #     render :status => :not_acceptable, :json => {
  #       message: "alcohol allowed at #{Settings.liquor_time}"
  #     } if error.message == 'not_allowed'
  #
  #     render :status => :bad_request, :json => '' if error.message == 'empty_items'
  #
  #     render :status => :request_entity_too_large, :json => {
  #       message: 'insufficient funds',
  #       balance: card.checkout_balance.balance,
  #       items: params[:items].to_a,
  #       costs: transaction.price
  #     } if error.message == 'insufficient_funds'
  #     return
  #   end
  #
  #   render :status => :created, :json => {
  #     uuid: card.uuid,
  #     first_name: card.member.first_name,
  #     balance: card.checkout_balance.balance,
  #     created_at: transaction.created_at
  #   }
  # end
  #
  # def add_card_to_member
  #   if !CheckoutCard.find_by_uuid(params[:uuid]).nil?
  #     render :status => :conflict, :json => ''
  #     return
  #   end
  #
  #   card = CheckoutCard.new( :uuid => params[:uuid], :member => Member.find_by_student_id!(params[:student]), :description => params[:description] )
  #
  #   if card.save
  #     render :status => :created, :json => CheckoutCard.joins(:member, :checkout_balance).select(:id, :uuid, :first_name, :balance).find_by_uuid!(params[:uuid]).to_json
  #     return
  #   else
  #     render :status => :conflict, :json => ''
  #     return
  #   end
  # end
  #
  # def activate_card
  #   card = CheckoutCard.find_by_uuid!(params[:uuid])
  #
  #   if params[:_destroy]
  #     card.destroy
  #
  #     render :status => :no_content, :json => ''
  #     return
  #   end
  #
  #   card.update_attribute(:active, true)
  #
  #   if card.save
  #     render :status => :ok, :json => card.to_json
  #     return
  #   else
  #     render :status => :bad_request, :json => ''
  #     return
  #   end
  # end
  #
  # def products_list
  #   render :status => :ok, :json => CheckoutProduct.where(:active => true).select(:id, :name, :category, :price).map{ |item| item.attributes.merge({ :image => CheckoutProduct.find_by_id( item.id ).url }) }
  # end

  private #TODO change to OAuth client_credentials
  def authenticate_checkout
    if params[:token] != ENV['CHECKOUT_TOKEN']
      render :status => :forbidden, :json => 'not authenticated'
      return
    end
  end
end
