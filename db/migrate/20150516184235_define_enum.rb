class DefineEnum < ActiveRecord::Migration    
  def change
    rename_column :tags, :name_id, :name
    remove_column :tags, :id, :integer
    
    #execute("ALTER TABLE `tags` CHANGE `name` `name` enum('pardon','merit','honorary') DEFAULT 'pardon'")
  end
end
