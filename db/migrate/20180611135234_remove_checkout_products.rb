class RemoveCheckoutProducts < ActiveRecord::Migration[5.1]
  def change
    drop_table "checkout_products", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC" do |t|
      t.string "name"
      t.integer "category"
      t.integer "parent"
      t.boolean "active", default: true
      t.decimal "price", precision: 6, scale: 2
      t.string "image_file_name"
      t.string "image_content_type"
      t.integer "image_file_size"
      t.datetime "image_updated_at"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer "storage_stock", default: 0
      t.integer "chamber_stock", default: 0
      t.bigint "checkout_product_type_id"
      t.index ["checkout_product_type_id"], name: "index_checkout_products_on_checkout_product_type_id"
    end
  end
end
