class CreateCheckoutProductTypes < ActiveRecord::Migration[5.1]
  def change
    create_table :checkout_product_types, id: :integer do |t|
      t.string :name
      t.integer :category
      t.boolean :active, default: true

      t.decimal :price, scale: 2, precision: 6

      t.attachment :image
      t.timestamps
    end
  end
end
