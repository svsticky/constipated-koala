class RemoveDefaultMemberJoinDate < ActiveRecord::Migration
  def change
    change_column_default(:members, :join_date, nil)
  end
end
