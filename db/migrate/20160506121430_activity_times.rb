class ActivityTimes < ActiveRecord::Migration[4.2]
  def change
	add_column :activities, :start_time, :time, :null => true, :after => :start_date
	add_column :activities, :end_time, :time, :null => true, :after => :end_date
  end
end
