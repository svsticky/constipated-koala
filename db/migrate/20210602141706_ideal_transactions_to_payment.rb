class IdealTransactionsToPayment < ActiveRecord::Migration[6.0]
  def up
    rename_table :ideal_transactions, :payments

    remove_column :payments, :transaction_type, :string

    add_column :payments, :transaction_type, :integer, default: 0
    add_column :payments, :payment_type, :integer, default: 0

    change_column :checkout_transactions, :payment_method, :string, limit: 16
  end
  def down
    change_column :checkout_transactions, :payment_method, :string, limit: 7
  end

end
