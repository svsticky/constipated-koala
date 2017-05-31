class AddIsMastersToActivity < ActiveRecord::Migration[4.2]
  def change
    add_column :activities, :is_masters, :bool
  end
end
