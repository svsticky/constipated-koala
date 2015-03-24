class ChangeActivity < ActiveRecord::Migration
  def change
    change_column :activities, :start_date, :datetime
    change_column :activities, :end_date, :datetime
    
    add_column :activities, :google_id, :string
    add_column :activities, :location, :string
    
    add_index :activities, :google_id, :unique => true
  end
end
