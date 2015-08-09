class CleanEducations < ActiveRecord::Migration
  def change
    remove_column :studies, :name
  end
end
