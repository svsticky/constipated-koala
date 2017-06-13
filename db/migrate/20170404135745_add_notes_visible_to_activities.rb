class AddNotesVisibleToActivities < ActiveRecord::Migration[4.2]
  def change
    add_column :activities, :notes_public, :boolean
  end
end
