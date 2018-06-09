#:nodoc:
class RemovePaperclip < ActiveRecord::Migration[5.2]
  def change
    remove_column :advertisements, :poster_file_name
    remove_column :advertisements, :poster_content_type
    remove_column :advertisements, :poster_file_size
    remove_column :advertisements, :poster_updated_at

    remove_column :checkout_products, :image_file_name
    remove_column :checkout_products, :image_content_type
    remove_column :checkout_products, :image_file_size
    remove_column :checkout_products, :image_updated_at
  end
end
