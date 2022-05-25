class AddIsPayableUpdatedAt < ActiveRecord::Migration[6.1]
  def change
    add_column :activities, :is_payable_updated_at, :timestamptz
    Activity.where(is_payable:true).update_all(is_payable_updated_at: DateTime.now-3.weeks)
  end
end
