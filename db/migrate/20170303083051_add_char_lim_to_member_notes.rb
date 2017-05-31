class AddCharLimToMemberNotes < ActiveRecord::Migration[4.2]
  def up
    change_column :participants, :notes, :string, :limit => 30
  end

  def down
    change_column :participants, :notes, :string, :limit => 255
  end
end
