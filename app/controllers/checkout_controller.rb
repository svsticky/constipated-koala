class CheckoutController < ApplicationController
  protect_from_forgery except: [:information_for_card, :subtract_funds, :add_card_to_member]
  skip_before_action :authenticate_admin!, only: [:information_for_card, :subtract_funds, :add_card_to_member]
  before_action
  
  respond_to :json
  respond_to :html, only: :index
  
  def index    
    @limit = params[:limit] ? params[:limit].to_i : 50
    @offset = params[:offset] ? params[:offset].to_i : 0
  
    @page = @offset / @limit
    @pagination = 5
 
    @transactions = CheckoutTransaction.joins(:checkout_card).all.select(:id, :created_at, :price, :checkout_card_id, :uuid, :description).order(created_at: :desc).limit(@limit).offset(@offset)
    @cards = CheckoutCard.joins(:member).select(:id, :uuid, :member_id).where(:active => false)
    
    @pages = CheckoutTransaction.count / @limit
  end

  def information_for_card
    respond_with CheckoutCard.joins(:member, :checkout_balance).select(:id, :uuid, :first_name, :balance).find_by_uuid!(params[:uuid])
  end

  def change_funds  
    
    if params[:uuid]
      card = CheckoutCard.joins(:checkout_balance).find_by_uuid(params[:uuid])
    elsif params[:id]
      #take a random card..
      card = Member.find_by_id!(params[:id]).checkout_cards.first
    end
    
    if card.nil?
      render :status => :not_found, :json => 'card not found' 
      return
    end
  
    transaction = CheckoutTransaction.new( :price => params[:amount], :checkout_card => card )
    transaction.save
    
    render :status => :created, :json => CheckoutTransaction.joins(:checkout_card).select(:id, :uuid, :price, :created_at).find_by_id!(transaction.id)
  end
  
  def subtract_funds
    if !params[:amount].is_number? || params[:amount].to_f >= 0
      render :status => :bad_request, :json => 'amount should be a negative numeric value'
      return
    end
    
    card = CheckoutCard.find_by_uuid!(params[:uuid])
    
    if( !card.active )
      render :status => :unauthorized, :json => 'card not yet activated'
      return
    end
    
    #in the constructor of transaction subtract from balance, check if it is a subtraction
    transaction = CheckoutTransaction.new( :price => params[:amount], :checkout_card => card )

    logger.debug transaction.inspect

    begin
      transaction.save
    rescue ActiveRecord::RecordNotSaved
      render :status => :request_entity_too_large, :json => 'insufficient funds'
      return
    end
  
    render :status => :created, :json => CheckoutTransaction.joins(:checkout_card).select(:id, :uuid, :price, :created_at).find_by_id!(transaction.id)
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
    card.update_attribute(:active, true);
    
    if card.save
      render :status => :ok, :json => card.to_json
      return
    else 
      render :status => :bad_request, :json => card.errors.full_messages
      return
    end
  end
end