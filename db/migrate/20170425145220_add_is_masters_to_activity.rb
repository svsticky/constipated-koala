class AddIsMastersToActivity < ActiveRecord::Migration
  def change
    add_column :activities, :is_masters, :bool
  end
end
