class AddMemberIdToAdmin < ActiveRecord::Migration
  def change
    add_column :admins, :member_id, :integer
    add_index :admins, :member_id
  end
end
