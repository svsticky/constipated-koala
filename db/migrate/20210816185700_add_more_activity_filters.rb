class AddMoreActivityFilters < ActiveRecord::Migration[6.1]
  def up
    add_column :activities, :is_sophomores, :boolean
    add_column :activities, :is_seniors, :boolean
  end
  def down
    remove_column :activities, :is_sophomores, :boolean
    remove_column :activities, :is_seniors, :boolean
  end
end
