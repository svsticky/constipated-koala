class CleanEducations < ActiveRecord::Migration[4.2]
  def change
    remove_column :studies, :name
  end
end
