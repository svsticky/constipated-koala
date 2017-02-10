class AddNotesToParticipants < ActiveRecord::Migration
  def change
    add_column :participants, :notes, :string
    add_column :activities, :notes, :string
  end
end
