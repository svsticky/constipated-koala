class CreateCheckoutTransactionItems < ActiveRecord::Migration[5.1]
  def change
    create_table :checkout_transaction_items, id: :integer do |t|
      t.references :checkout_transaction
      t.references :checkout_product_type
      t.decimal    :price, precision: 6, scale: 2
    end
  end
end
