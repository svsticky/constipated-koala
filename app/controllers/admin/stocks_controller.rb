class Admin::StocksController < ApplicationController
  def stock
    @products = CheckoutProduct.order(:category, :name)

    render 'admin/apps/stocky/stock'
  end

  def purchases
    @purchases = StockyTransaction.order(:created_at)
    @products = CheckoutProduct.order(:category, :name)

    render 'admin/apps/stocky/purchases'
  end

  def sales
    render 'admin/apps/stocky/sales'
  end
end
