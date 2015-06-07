class Admins::CheckoutController < ApplicationController
  protect_from_forgery except: [:information_for_card, :subtract_funds, :add_card_to_member, :products_list]
  
  skip_before_action :authenticate_user!, only: [:information_for_card, :subtract_funds, :add_card_to_member, :products_list]
  skip_before_action :authenticate_admin!, only: [:information_for_card, :subtract_funds, :add_card_to_member, :products_list]
    
  before_action :authenticate_checkout, only: [:information_for_card, :subtract_funds, :add_card_to_member, :products_list]
  
  respond_to :json
  respond_to :html, only: [:index, :products]
  
  def index    
    @limit = params[:limit] ? params[:limit].to_i : 50
    @offset = params[:offset] ? params[:offset].to_i : 0
  
    @page = @offset / @limit
    @pagination = 5
 
    @transactions = CheckoutTransaction.includes(:checkout_card).order(created_at: :desc).limit(@limit).offset(@offset)
    @cards = CheckoutCard.joins(:member).select(:id, :uuid, :member_id).where(:active => false)
    
    @pages = CheckoutTransaction.count / @limit
  end

  def information_for_card
    respond_with CheckoutCard.joins(:member, :checkout_balance).select(:id, :uuid, :first_name, :balance).find_by_uuid!(params[:uuid])
  end

  def change_funds      
    if params[:uuid]
      card = CheckoutCard.joins(:checkout_balance).find_by_uuid(params[:uuid])
      transaction = CheckoutTransaction.new( :price => params[:amount], :checkout_card => card )
      
    elsif params[:member_id]        
      transaction = CheckoutTransaction.new( :price => params[:amount], :checkout_balance => CheckoutBalance.find_by_member_id!(params[:member_id]) )

    else
      render :status => :bad_request, :json => 'no identifier given'
      return
    end
    
    begin
      transaction.save
    rescue ActiveRecord::RecordNotSaved => exception
      render :status => :request_entity_too_large, :json => exception.message
      return
    rescue ActiveRecord::RecordInvalid
      render :status => :bad_request, :json => exception.message
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

    # TODO deze if weghalen
    if params[:items].nil?          
      if !params[:amount].is_number? || params[:amount].to_f >= 0
        render :status => :bad_request, :json => 'amount should be a negative numeric value'
        return
      end
      
      transaction = CheckoutTransaction.new( :price => params[:amount], :checkout_card => card )
    end
    
    begin
      transaction.save
    rescue ActiveRecord::RecordInvalid => error
      render :status => :bad_request, :json => error.message
      return
    rescue ActiveRecord::RecordNotSaved => error
      render :status => :request_entity_too_large, :json => error.message
      return
    end
  
    render :status => :created, :json => transaction.created_at
  end
  
  def add_card_to_member    
    if !CheckoutCard.find_by_uuid(params[:uuid]).nil?
      render :status => :conflict, :json => 'card already registered'
      return
    end
    
    card = CheckoutCard.new( :uuid => params[:uuid], :member => Member.find_by_student_id!(params[:student]), :description => params[:description] )
    
    if card.save(:validate => false)
      render :status => :created, :json => CheckoutCard.joins(:member, :checkout_balance).select(:id, :uuid, :first_name, :balance).find_by_uuid!(params[:uuid]).to_json
      return
    else
      render :status => :conflict, :json => card.errors.full_messages
      return
    end
  end
  
  def activate_card
    card = CheckoutCard.find_by_uuid!(params[:uuid])
    
    if params[:_destroy]
      card.destroy
      
      # balance weghalen als er geen transacties zijn?
      
      render :status => :no_content, :json => ''
      return
    end
    
    card.update_attribute(:active, true)
    
    if card.save
      render :status => :ok, :json => card.to_json
      return
    else 
      render :status => :bad_request, :json => card.errors.full_messages
      return
    end
  end
  
  def products
    @product = CheckoutProduct.new
    @products = CheckoutProduct.where(:active =>  true).order(:category, :name)
  end  
  
  def products_list
    render :status => :ok, :json => CheckoutProduct.where(:active => true).select(:id, :name, :category, :price)
  end
  
  def create_product
    @product = CheckoutProduct.new(product_post_params)
  
    if @product.save
      redirect_to checkout_products_path
    else
      @products = CheckoutProduct.all
      render 'products'
    end
  end
  
  def delete_product
    product = CheckoutProduct.find(params[:id])
    product.update_attribute(:active, 'false')
    
    if product.save
      render :status => :no_content, :json => ''
      return
    else 
      render :status => :bad_request, :json => product.errors.full_messages
      return
    end
  end
  
  private 
  def authenticate_checkout
    if params[:token] != ConstipatedKoala::Application.config.checkout
      render :status => :forbidden, :json => 'not authenticated'
      return
    end
  end
  
  def product_post_params
    params.require(:checkout_product).permit( :name,
                                              :price,
                                              :category,
                                              :image)
  end
end
