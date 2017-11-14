class Admin::StocksController < ApplicationController
  def index
    @products = CheckoutProduct.order(:category, :name).last_version

    render 'admin/apps/stocky/voorraad'
  end
end
