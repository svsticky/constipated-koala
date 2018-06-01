#:nodoc:
class AddLocationToActivity < ActiveRecord::Migration[4.2]
  def change
    add_column :activities, :location, :string
  end
end
