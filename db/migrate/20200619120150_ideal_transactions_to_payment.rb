class IdealTransactionsToPayment < ActiveRecord::Migration[6.0]
  def change
    rename_table :ideal_transactions, :payments
    rename_column :payments, :redirect_uri, :ideal_redirect_uri

    remove_column :payments, :transaction_type, :string

    add_column :payments, :transaction_type, :integer, default: 0
    add_column :payments, :payment_type, :integer, default: 0

    change_column :checkout_transactions, :payment_method, :string, limit: 16
  end
end
