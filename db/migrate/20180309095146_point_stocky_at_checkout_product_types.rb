class PointStockyAtCheckoutProductTypes < ActiveRecord::Migration[5.1]
  def change
    rename_column :stocky_transactions, :checkout_product_id, :checkout_product_type_id
  end
end
