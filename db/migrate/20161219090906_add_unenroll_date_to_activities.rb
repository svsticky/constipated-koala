class AddUnenrollDateToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :unenroll_date, :date
  end
end
