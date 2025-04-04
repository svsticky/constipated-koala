class AddIsPayableUpdatedAt < ActiveRecord::Migration[6.1]
  def up
    add_column :activities, :payable_updated_at, :date
    Activity.where(is_payable:true).update_all(payable_updated_at: Date.today-3.weeks)
  end

  def down
    remove_column :activities, :payable_updated_at
  end
end
