class Admin::StocksController < ApplicationController
  def stock
    @products = CheckoutProductType.order(:category, :name)
    @stocky_transaction      = StockyTransaction.new
    @moves = StockyTransaction
             .where(:from => ['basement', 'mongoose'])
             .where(:to   => ['basement', 'mongoose',
                              'activity', 'waste'])
             .order(created_at: :desc)

    @chart_data = @products.map{ |i| [i.name, i.chamber_stock + i.storage_stock]}

    render 'admin/apps/stocky/stock'
  end

  def purchases
    @results = StockyTransaction.where(from: "shop").order(:created_at)
    @stocky_transaction      = StockyTransaction.new

    @limit = params[:limit] ? params[:limit].to_i : 20
    @offset = params[:offset] ? params[:offset].to_i : 0

    @page = @offset / @limit
    @pages = (@results.count / @limit.to_f).ceil

    @purchases = @results[@offset,@limit]

    @transactions = StockyTransaction.where(from: "shop")

    @product_ids = @transactions.pluck(:checkout_product_type_id).uniq

    @products = CheckoutProductType.where(id: @product_ids)

    @chart_data = @transactions.pluck(:checkout_product_type_id).uniq.map{ |i| {
      name: CheckoutProductType.find(i).name,
      data: @transactions.where(checkout_product_type_id: i).pluck('DATE(created_at)', :amount),
      library: {
        spanGaps: true,
        lineTension: 0.0,
        pointHoverBorderWidth: 10
      }
    }}

    render 'admin/apps/stocky/purchases'
  end

  def create
    @stocky_transaction      = StockyTransaction.new(
      stocky_transaction_post_params)

    @stocky_transaction.save

    stock
  end

  def create_purchase
    @stocky_transaction      = StockyTransaction.new(
      stocky_purchase_transaction_post_params)
    @stocky_transaction.from = "shop"
    @stocky_transaction.to   = "basement"

    @stocky_transaction.save

    purchases
  end

  def sales
    @results = StockyTransaction.where(from: "mongoose").order(:created_at)
    @stocky_transaction = StockyTransaction.new

    @limit  = params[:limit]  ? params[:limit] .to_i : 20
    @offset = params[:offset] ? params[:offset].to_i :  0

    @page  = @offset / @limit
    @pages = (@results.count / @limit.to_f).ceil

    @sales = @results[@offset,@limit]

    render 'admin/apps/stocky/sales'
  end

  private
  def stocky_purchase_transaction_post_params
    params.require(:stocky_transaction)
      .permit(:checkout_product_type_id,
              :amount)
  end

  private
  def stocky_transaction_post_params
    params.require(:stocky_transaction)
      .permit(:checkout_product_type_id,
              :amount,
              :from,
              :to)
  end
end
