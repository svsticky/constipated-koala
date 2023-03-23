class AddSacPoints < ActiveRecord::Migration[6.1]
  def change
    add_column :activities, :sac_category, :integer
    add_column :participants, :sac_points, :integer
  end
end
