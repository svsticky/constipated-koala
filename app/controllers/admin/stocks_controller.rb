class Admin::StocksController < ApplicationController
  def stock
    @products = CheckoutProduct.order(:category, :name)
    @stocky_transaction      = StockyTransaction.new

    render 'admin/apps/stocky/stock'
  end

  def purchases
    @purchases = StockyTransaction.where(from: "shop").order(:created_at)
    @stocky_transaction      = StockyTransaction.new

    render 'admin/apps/stocky/purchases'
  end

  def create
    @stocky_transaction      = StockyTransaction.new(
      stocky_transaction_post_params)

    @stocky_transaction.save
  end

  def create_purchase
    @stocky_transaction      = StockyTransaction.new(
      stocky_purchase_transaction_post_params)
    @stocky_transaction.from = "shop"
    @stocky_transaction.to   = "basement"

    @stocky_transaction.save
  end

  def sales
    render 'admin/apps/stocky/sales'
  end

  private
  def stocky_purchase_transaction_post_params
    params.require(:stocky_transaction)
      .permit(:checkout_product_id,
              :amount)
  end

  private
  def stocky_transaction_post_params
    params.require(:stocky_transaction)
      .permit(:checkout_product_id,
              :amount,
              :from,
              :to)
  end
end
