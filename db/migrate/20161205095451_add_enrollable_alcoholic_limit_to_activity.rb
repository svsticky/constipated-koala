class AddEnrollableAlcoholicLimitToActivity < ActiveRecord::Migration
  def change
    add_column :activities, :is_enrollable, :boolean
    add_column :activities, :is_alcoholic, :boolean
    add_column :activities, :participant_limit, :int
  end
end
