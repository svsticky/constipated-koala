class FixStockyTransactionProductReference < ActiveRecord::Migration[5.1]
  def change
    change_table :stocky_transactions do |t|
      t.remove :product_id
      t.references :checkout_product
    end
  end
end
