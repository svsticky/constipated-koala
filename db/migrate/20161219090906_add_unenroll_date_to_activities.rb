class AddUnenrollDateToActivities < ActiveRecord::Migration[4.2]
  def change
    add_column :activities, :unenroll_date, :date
  end
end
