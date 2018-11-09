class AddShowOnWebsiteToActivities < ActiveRecord::Migration[5.2]
  def change
    add_column :activities, :show_on_website, :boolean, null: false, default: false
  end
end
