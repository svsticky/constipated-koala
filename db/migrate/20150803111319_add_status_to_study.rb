#:nodoc:
class AddStatusToStudy < ActiveRecord::Migration[4.2]
  def change
    add_column :studies, :active, :boolean, :null => false, :default => true
  end
end
