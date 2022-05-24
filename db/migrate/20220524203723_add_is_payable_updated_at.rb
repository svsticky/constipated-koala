class AddIsPayableUpdatedAt < ActiveRecord::Migration[6.1]
  def change
    add_column :activities, :is_payable_updated_at, :timestamptz
  end
end
