class CreatePosts < ActiveRecord::Migration[6.0]
  def change
    create_table :posts do |t|
      t.text :content

      t.integer :status, :null => false, :default => 0
      t.string :tags

      t.belongs_to :author, :polymorphic => true, :null => false

      t.timestamps
      t.datetime :published_at
    end
  end
end
