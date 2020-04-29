class MultilingualActivityDescription < ActiveRecord::Migration[6.0]
  def change
    rename_column :activities, :description, :description_nl
    add_column :activities, :description_en, :text
  end
end
