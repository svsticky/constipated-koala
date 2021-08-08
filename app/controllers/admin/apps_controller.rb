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

  def transactions
    @transactions = Payment.order(created_at: :desc)

    @transactions = @transactions.search_by_name(params[:search]) unless params[:search].blank?
    @transactions = @transactions.where(transaction_type: params[:transaction_type]) unless params[:transaction_type].blank?
    @transactions = @transactions.where(payment_type: params[:payment_type]) unless params[:payment_type].blank?
    @transactions = @transactions.where(status: params[:status]) unless params[:status].blank?
    @pagination, @transactions = pagy(@transactions, items: params[:limit] ||= 20)
  end

  def transactions_params
    params.require(:payment).permit(:transaction_type, :payment_type, :status, :search)
  end
end
