class AddCalendarIdToMember < ActiveRecord::Migration[6.1]
  def change
    add_column :members, :calendar_id, :uuid
  end
end
