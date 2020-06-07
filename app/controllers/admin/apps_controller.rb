#:nodoc:
class Admin::AppsController < ApplicationController
  def checkout
    @pagination = 5

    @pagination, @transactions = pagy(CheckoutTransaction.includes(:checkout_card)
      .order(created_at: :desc), items: params[:limit] ||= 20)

    @cards = CheckoutCard.joins(:member).select(:id, :uuid, :member_id).where(:active => false)

    @credit = CheckoutBalance.sum(:balance)
    @products = CheckoutProduct.where(:active => true).count
  end

  def ideal
    @pagination, @transactions = pagy(IdealTransaction.order(created_at: :desc), items: params[:limit] ||= 20)
  end
end
