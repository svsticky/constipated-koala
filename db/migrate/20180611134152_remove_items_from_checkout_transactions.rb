class RemoveItemsFromCheckoutTransactions < ActiveRecord::Migration[5.1]
  def change
    remove_column :checkout_transactions, :items, :string
  end
end
