class AddIsViewable < ActiveRecord::Migration
  def change
    add_column :activities, :is_viewable, :boolean
  end
end
