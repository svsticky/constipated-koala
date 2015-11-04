class Admin::AppsController < ApplicationController

  def checkout
    @limit = params[:limit] ? params[:limit].to_i : 50
    @offset = params[:offset] ? params[:offset].to_i : 0

    @page = @offset / @limit
    @pagination = 5

    @transactions = CheckoutTransaction.includes(:checkout_card).order(created_at: :desc).limit(@limit).offset(@offset)
    @cards = CheckoutCard.joins(:member).select(:id, :uuid, :member_id).where(:active => false)

    @credit = CheckoutBalance.sum( :balance )
    @products = CheckoutProduct.count( :active => true)

    @pages = CheckoutTransaction.count / @limit
  end

  def products
    @products = CheckoutProduct.order(:category, :name).last_version
    @years = (2015 .. Date.today.study_year ).map{ |year| ["#{year}-#{year +1}", year] }.reverse

    @product = CheckoutProduct.find( params[:id] ) unless params[:id].nil?
    @total = @product.sales( params['year']).map{ |sale| sale.first[0].price * sale.first[1] unless sale.first[1].nil? }.compact.inject(:+) unless params[:id].nil?
    @new = CheckoutProduct.new if params[:id].nil?
  end

  def create_product
    @new = CheckoutProduct.new(product_post_params)

    if @new.save
      redirect_to apps_product_path(@new)
    else
      @products = CheckoutProduct.order(:category, :name).last_version
      @years = (2015 .. Date.today.study_year ).map{ |year| ["#{year}-#{year +1}", year] }.reverse

      render 'admins/apps/products'
    end
  end

  def update_product
    @product = CheckoutProduct.find(params[:id])

    if @product.update(product_post_params)
      # if a new product is created redirect to it
      product = CheckoutProduct.find_by_parent(@product.id)

      redirect_to apps_product_path( product || @product.id )
    else
      @years = (2015 .. Date.today.study_year ).map{ |year| ["#{year}-#{year +1}", year] }.reverse
      @products = CheckoutProduct.order(:category, :name).last_version

      render 'admins/apps/products'
    end
  end

  def ideal
    @transactions = IdealTransaction.find_by_date( params['date'] || Date.yesterday )
    @summary = IdealTransaction.summary( @transactions )
  end

  private
  def product_post_params
    params.require(:checkout_product).permit( :name,
                                              :price,
                                              :category,
                                              :active,
                                              :image)
  end
end
