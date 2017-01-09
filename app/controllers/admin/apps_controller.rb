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
    begin
      @transactions = IdealTransaction.list( params[:limit] ||= 20, params[:offset] ||= 0 )
      flash[:warning] = nil

    # rescue ArgumentError
    #   # redirect or something other than 200
    #   flash[:warning] = I18n.t :no_connection, scope: 'activerecord.errors', :name => 'transacties', :url => ENV['IDEAL_PLATFORM']
    #   @transactions = IdealTransaction.none
    #
    # rescue SocketError
    #   # no connection, DNS problems for example, notify user
    #   flash[:warning] = I18n.t :no_connection, scope: 'activerecord.errors', :name => 'transacties', :url => ENV['IDEAL_PLATFORM']
    #   @transactions = IdealTransaction.none

    end

    @limit = params[:limit] ? params[:limit].to_i : 50
    @offset = params[:offset] ? params[:offset].to_i : 0
  end
end
