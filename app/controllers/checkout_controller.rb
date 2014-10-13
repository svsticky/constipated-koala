class CheckoutController < ApplicationController
  protect_from_forgery except: [:information_for_card, :subtract_funds, :add_card_to_member]
  skip_before_action :authenticate_admin!, only: [:information_for_card, :subtract_funds, :add_card_to_member]
  respond_to :json

  def information_for_card
    card = CheckoutCard.find(params[:id])
    respond_with card.joins(:member, :checkout_balance).select(:id, :first_name, :uuid, :balance)
  end

  def add_funds      
    card = CheckoutCard.find(params[:id])
    
    transaction = CheckoutTransaction.new( :price => params[:amount], :checkout_card => @card )
    transaction.save
    
    respond_with transaction, :location => checkout_url
  end
  
  def subtract_funds
    card = CheckoutCard.find(params[:id])
    
    #in the constructor of transaction subtract from balance, check if it is a subtraction
    transaction = CheckoutTransaction.new( :price => params[:amount], :checkout_card => @card )
    transaction.save
    
    respond_with transaction
  end
  
  def add_card_to_member
    #on new card create new of find balance of member
    card = CheckoutCard.new( :uuid => params[:uuid], :member => Member.find(params[:member]), :description => params[:description] )
    
    if card.save 
      render :status => :ok, :json => card.joins(:member, :checkout_balance).select(:id, :first_name, :uuid, :balance )
    else
      logger.error card.inspect
      respond_with card.errors.full_messages, :location => checkout_url
    end
  end
end
