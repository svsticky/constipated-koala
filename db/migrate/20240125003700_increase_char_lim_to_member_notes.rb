class IncreaseCharLimToMemberNotes < ActiveRecord::Migration[6.1]
  def up
    change_column :participants, :notes, :string, :limit => 100
  end

  def down
    change_column :participants, :notes, :string, :limit => 30
  end
end
