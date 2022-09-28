class PinPostsInDatabase < ActiveRecord::Migration[6.1]
  def change
    add_column :posts, :pinned, :boolean, :null => false, default: false
  end
end
