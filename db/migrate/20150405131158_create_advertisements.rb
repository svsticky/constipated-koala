class CreateAdvertisements < ActiveRecord::Migration
  def change
    create_table :advertisements do |t|
      t.string :name
      t.boolean :visible
      
      t.attachment :poster
      t.timestamps
    end
  end
end
