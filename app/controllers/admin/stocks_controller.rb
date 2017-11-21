class Admin::StocksController < ApplicationController
  def stock
    @products = CheckoutProduct.order(:category, :name).last_version

    render 'admin/apps/stocky/stock'
  end

  def purchases
    render 'admin/apps/stocky/purchases'
  end

  def sales
    render 'admin/apps/stocky/sales'
  end
end
