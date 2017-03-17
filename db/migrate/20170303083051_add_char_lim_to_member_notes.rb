class AddCharLimToMemberNotes < ActiveRecord::Migration
  def up
    change_column :participants, :notes, :string, :limit => 30
  end

  def down
    change_column :participants, :notes, :string, :limit => 255
  end
end
