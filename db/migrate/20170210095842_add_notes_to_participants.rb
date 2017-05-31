class AddNotesToParticipants < ActiveRecord::Migration[4.2]
  def change
    add_column :participants, :notes, :string
    add_column :activities, :notes, :string
  end
end
