class AddEnrollableDate < ActiveRecord::Migration[6.1]
  def up
    add_column :activities, :open_date, :date, :after => :open_time
    add_column :activities, :open_time, :time, :null => true, :after => :open_date
  end

  def down
    remove_column :activities, :open_date
    remove_column :activities, :open_time
  end
end
