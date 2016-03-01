class AddParentToCheckoutProduct < ActiveRecord::Migration
  def change    
    add_reference :checkout_products, :checkout_product, after: :category
    rename_column :checkout_products, :checkout_product_id, :parent
  end
end
