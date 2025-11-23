class AddIncludeInWeekoverzichtToActivities < ActiveRecord::Migration[6.1]
  def change
    add_column :activities, :include_in_weekoverzicht, :bool, default: true
  end
end
