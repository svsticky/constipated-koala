class AddNotesVisibleToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :notes_public, :boolean
  end
end
