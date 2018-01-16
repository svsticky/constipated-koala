class AddPriceToStockyTransaction < ActiveRecord::Migration[5.1]
  def change
    add_column :stocky_transactions, :price, :decimal, null: true
  end
end
