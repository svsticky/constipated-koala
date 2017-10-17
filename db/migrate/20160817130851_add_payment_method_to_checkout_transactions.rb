class AddPaymentMethodToCheckoutTransactions < ActiveRecord::Migration[4.2]
  def change
  change_table :checkout_transactions do |t|
      t.string	 :payment_method, limit: 7
    end
  end
end
