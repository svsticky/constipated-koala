class AddNotesInputTypeToActivities < ActiveRecord::Migration[6.1]
  def change
    add_column :activities, :notes_input_type, :integer, default: 0
  end
end
