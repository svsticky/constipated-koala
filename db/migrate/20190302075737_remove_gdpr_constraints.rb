class RemoveGdprConstraints < ActiveRecord::Migration[5.2]
  def change
    change_column :checkout_balances, :member_id, :integer, :null => true
    remove_column :members, :gender
  end
end
