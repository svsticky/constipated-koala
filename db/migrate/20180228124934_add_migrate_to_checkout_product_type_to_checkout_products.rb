class AddMigrateToCheckoutProductTypeToCheckoutProducts < ActiveRecord::Migration[5.1]
  def change
    add_reference :checkout_products, :checkout_product_type
  end
end
