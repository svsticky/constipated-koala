class ActivityTimes < ActiveRecord::Migration
  def change
	add_column :activities, :start_time, :time, :null => true
	add_column :activities, :end_time, :time, :null => true
  end
end
