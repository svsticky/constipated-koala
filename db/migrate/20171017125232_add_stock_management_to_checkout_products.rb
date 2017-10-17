class AddStockManagementToCheckoutProducts < ActiveRecord::Migration[5.1]
  def change
    add_column :checkout_products, :storage_stock, :integer, default: 0
    add_column :checkout_products, :chamber_stock, :integer, default: 0
  end
end
