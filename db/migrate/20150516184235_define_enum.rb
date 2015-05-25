class DefineEnum < ActiveRecord::Migration    
  def change
    rename_column :tags, :name_id, :name
    remove_column :tags, :id
    
    #execute("ALTER TABLE `tags` CHANGE `name` `name` enum('pardon','merit','honorary') DEFAULT 'pardon'")
    change_column :tags, :name, :enum, :limit => ['pardon','merit','honorary']
  end
end
