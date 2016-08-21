class AddPaymentMethodToCheckoutTransactions < ActiveRecord::Migration
  def change
	change_table :checkout_transactions do |t|
      t.string	 :payment_method, limit: 7
    end
  end
end
