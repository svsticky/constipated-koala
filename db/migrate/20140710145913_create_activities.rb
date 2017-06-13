class CreateActivities < ActiveRecord::Migration[4.2]
  def change
    create_table :activities do |t|
      t.string :name
      
      t.date :start_date
      t.date :end_date
      
      t.decimal :price, :scale => 2, :precision => 6
      
      t.text :comments
      t.timestamps
    end
    
    create_table :participants do |t|
      t.belongs_to :member
      t.belongs_to :activity
      
      t.decimal :price, :scale => 2, :precision => 6
      t.boolean :paid, :default => false
      
      t.timestamps
    end
    
    add_index :participants, [:member_id, :activity_id], :unique => true
  end
end
