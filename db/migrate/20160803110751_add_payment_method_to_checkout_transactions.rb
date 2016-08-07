class AddPaymentMethodToCheckoutTransactions < ActiveRecord::Migration
  def change
	change_table :checkout_transactions do |t|
      t.integer	 :payment_method
    end
  end
end
