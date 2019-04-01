class RemoveGdprConstraints < ActiveRecord::Migration[5.2]
  def change
    change_column :checkout_balances, :member_id, :integer, :null => true
    remove_column :members, :gender

    add_column :members, :consent_at, :date, after: :comments
    add_column :members, :consent, :integer, default: 0, after: :comments
  end
end
