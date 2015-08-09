class AddStatusToStudy < ActiveRecord::Migration
  def change
    add_column :studies, :active, :boolean, :null => false, :default => true
  end
end
