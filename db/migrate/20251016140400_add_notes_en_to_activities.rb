class AddNotesEnToActivities < ActiveRecord::Migration[6.1]
  def change
    add_column :activities, :notes_en, :string
    rename_column :activities, :notes, :notes_nl
  end
end
