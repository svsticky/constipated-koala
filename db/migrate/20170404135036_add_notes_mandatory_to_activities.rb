#:nodoc:
class AddNotesMandatoryToActivities < ActiveRecord::Migration[4.2]
  def change
    add_column :activities, :notes_mandatory, :boolean
  end
end
