class AddParentToCheckoutProduct < ActiveRecord::Migration[4.2]
  def change
    add_reference :checkout_products, :checkout_product, after: :category
    rename_column :checkout_products, :checkout_product_id, :parent
  end
end
