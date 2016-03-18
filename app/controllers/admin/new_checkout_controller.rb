class Admin::CheckoutController < ApplicationController
  impressionist :actions => [ :activate_card, :change_funds ]

  respond_to :json

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
end
