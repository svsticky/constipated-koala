#:nodoc:
class RemoveDefaultMemberJoinDate < ActiveRecord::Migration[4.2]
  def change
    change_column_default(:members, :join_date, nil)
  end
end
