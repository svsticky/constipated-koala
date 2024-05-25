class AddCalendarIdToMember < ActiveRecord::Migration[6.1]
  def up
    add_column :members, :calendar_id, :uuid

    # Populate existing records with a random UUID
    Member.reset_column_information
    Member.find_each do |record|
      record.update_columns(calendar_id: SecureRandom.uuid)
    end

    # Add an index to the UUID column, because why not
    add_index :members, :calendar_id, unique: true
  end

  def down
    remove_column :members, :calendar_id
  end
end
