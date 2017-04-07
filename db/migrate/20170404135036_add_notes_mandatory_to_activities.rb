class AddNotesMandatoryToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :notes_mandatory, :boolean
  end
end
