#:nodoc:
class AddIsViewable < ActiveRecord::Migration[4.2]
  def change
    add_column :activities, :is_viewable, :boolean
  end
end
