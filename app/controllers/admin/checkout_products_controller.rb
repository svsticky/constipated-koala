#:nodoc:
class Admin::CheckoutProductsController < ApplicationController
  # replaced with calls in each of the methods
  # impressionist :actions => [ :activate_card, :change_funds ]
  respond_to :json, only: [:activate_card, :change_funds]

  def index
    @products = CheckoutProduct.order(active: :desc, category: :asc, name: :asc).last_version
    @years = (2015..Date.today.study_year).map { |year| ["#{ year }-#{ year + 1 }", year] }.reverse

    @new = CheckoutProduct.new

    render 'admin/apps/products'
  end

  def show
    @products = CheckoutProduct.order(active: :desc, category: :asc, name: :asc).last_version
    @years = (2015..Date.today.study_year).map { |year| ["#{ year }-#{ year + 1 }", year] }.reverse

    @product = CheckoutProduct.find_by(id: params[:id])
    @total = @product.sales(params['year']).map { |sale| sale.first[0].price * sale.first[1] unless sale.first[1].nil? }.compact.inject(:+)

    render 'admin/apps/products'
  end

  def create
    @new = CheckoutProduct.new product_post_params

    if @new.save
      redirect_to checkout_product_path(@new)
    else
      @products = CheckoutProduct.order(:category, :name).last_version
      @years = (2015..Date.today.study_year).map { |year| ["#{ year }-#{ year + 1 }", year] }.reverse

      render 'admin/apps/products'
    end
  end

  def update
    @product = CheckoutProduct.find_by id: params[:id]

    if @product.update(product_post_params)
      # if a new product is created redirect to it
      product = CheckoutProduct.find_by(parent: @product.id)
      prod_id = product ? product.id.to_s : @product.id.to_s

      redirect_to checkout_product_path(product || @product.id, anchor: "product_#{ prod_id }")
    else
      @years = (2015..Date.today.study_year).map { |year| ["#{ year }-#{ year + 1 }", year] }.reverse
      @products = CheckoutProduct.order(:category, :name).last_version

      render 'admin/apps/products'
    end
  end

  def flip_active
    @product = CheckoutProduct.find params[:checkout_product_id]

    head :internal_server_error unless @product.update(product_flipactive_params)
  end

  def change_funds
    if params[:uuid]
      card = CheckoutCard.joins(:checkout_balance).find_by(uuid: params[:uuid])
      transaction = CheckoutTransaction.new(price: params[:amount], checkout_card: card)

    elsif params[:member_id]
      transaction = CheckoutTransaction.new(price: params[:amount], checkout_balance: CheckoutBalance.find_by!(member_id: params[:member_id]), payment_method: params[:payment_method])

    else
      render status: :bad_request, json: I18n.t('checkout.error.identifier')
      return
    end

    if transaction.save
      impressionist transaction
      render status: :created, json: transaction
    else
      render status: :bad_request, json: {
        errors: transaction.errors
      }
    end
  end

  def activate_card
    card = CheckoutCard.find_by!(uuid: params[:uuid])

    if params[:_destroy]
      card.destroy

      render status: :no_content, json: ''
      return
    end

    card.update(active: true)

    if card.save
      impressionist card
      render status: :ok, json: card.to_json
    else
      render status: :bad_request, json: card.errors.full_messages
    end
  end

  private

  def product_post_params
    params.require(:checkout_product).permit(:name,
                                             :price,
                                             :category,
                                             :active,
                                             :image)
  end

  def product_flipactive_params
    params.require(:checkout_product).permit(:active)
  end
end
