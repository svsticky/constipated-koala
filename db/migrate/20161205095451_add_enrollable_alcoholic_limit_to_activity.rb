#:nodoc:
class AddEnrollableAlcoholicLimitToActivity < ActiveRecord::Migration[4.2]
  def change
    add_column :activities, :is_enrollable, :boolean
    add_column :activities, :is_alcoholic, :boolean
    add_column :activities, :participant_limit, :int
  end
end
