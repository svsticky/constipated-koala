class CheckoutController < ApplicationController
  protect_from_forgery except: [:information_for_card, :subtract_funds, :add_card_to_member]
  skip_before_action :authenticate_admin!, only: [:information_for_card, :subtract_funds, :add_card_to_member]
  respond_to :json

  def information_for_card
    respond_with CheckoutCard.joins(:member, :checkout_balance).select(:id, :uuid, :first_name, :uuid, :balance).find_by_uuid(params[:uuid])
  end

  def add_funds  
    card = CheckoutCard.joins(:checkout_balance).find_by_uuid(params[:uuid])
    
    transaction = CheckoutTransaction.new( :price => params[:amount], :checkout_card => card )
    transaction.save
    
    respond_with transaction, :location => checkout_url
  end
  
  def subtract_funds
    if params[:amount].to_f > 0
      raise ActiveRecord::RecordNotSaved
    end
  
    card = CheckoutCard.joins(:checkout_balance).find_by_uuid(params[:uuid])
    
    #in the constructor of transaction subtract from balance, check if it is a subtraction
    transaction = CheckoutTransaction.new( :price => params[:amount], :checkout_card => card )
    transaction.save
    
    respond_with transaction, :location => checkout_url
  end
  
  def add_card_to_member
    #on new card create new of find balance of member
    card = CheckoutCard.new( :uuid => params[:uuid], :member => Member.find(params[:member]), :description => params[:description] )
    
    if card.save(:validate => false)
      render :status => :ok, :json => card#.joins(:member, :checkout_balance).select(:id, :first_name, :uuid, :balance )
    else
      logger.error card.inspect
      respond_with card.errors.full_messages, :location => checkout_url
    end
  end
end