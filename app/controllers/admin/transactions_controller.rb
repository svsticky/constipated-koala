#:nodoc:
class Admin::TransactionsController < ApplicationController
  def index
    @transactions = Payment.order(created_at: :desc)

    @transactions = @transactions.search_by_name(params[:search]) if params[:search].present?
    if params[:transaction_type].present?
      @transactions = @transactions.where(transaction_type: params[:transaction_type])
    end
    @transactions = @transactions.where(payment_type: params[:payment_type]) if params[:payment_type].present?
    @transactions = @transactions.where(status: params[:status]) if params[:status].present?
    @pagination, @transactions = pagy(@transactions, items: params[:limit] ||= 20)
  end

  def transactions_params
    params.require(:payment).permit(:transaction_type, :payment_type, :status, :search)
  end
end
