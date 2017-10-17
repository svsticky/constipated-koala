class Admin::AppsController < ApplicationController
  def checkout
    @limit = params[:limit] ? params[:limit].to_i : 50
    @offset = params[:offset] ? params[:offset].to_i : 0

    @page = @offset / @limit
    @pagination = 5

    @transactions = CheckoutTransaction.includes(:checkout_card).order(created_at: :desc).limit(@limit).offset(@offset)
    @cards = CheckoutCard.joins(:member).select(:id, :uuid, :member_id).where(:active => false)

    @credit = CheckoutBalance.sum( :balance )
    @products = CheckoutProduct.where( :active => true ).count

    @pages = CheckoutTransaction.count / @limit
  end

  def ideal
    @transactions = IdealTransaction.order(created_at: :desc).limit( params[:limit] ||= 20 ).offset( params[:offset] ||= 0 )
    @limit = params[:limit] ? params[:limit].to_i : 50
    @offset = params[:offset] ? params[:offset].to_i : 0
  end
end
