class AddFreshmansToActivities < ActiveRecord::Migration[5.1]
  def change
    add_column :activities, :is_freshmans, :bool
  end
end
