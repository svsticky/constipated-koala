class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.string :name
      t.text :comments
      
      t.integer :year
      t.integer :type
      
      t.timestamps
    end

    create_table :group_members do |t|
      t.belongs_to :member
      t.belongs_to :group
      
      t.string :position
      
      t.timestamps
    end

    add_index :group_members, [:member_id, :group_id, :year], :unique => true
    
    add_column :activities, :organized_by, :somethgin something
  end
end