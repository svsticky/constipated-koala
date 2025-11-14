class AddCostUnitToActivities < ActiveRecord::Migration[6.1]
  def change
    add_column :activities, :cost_unit, :string
  end
end
