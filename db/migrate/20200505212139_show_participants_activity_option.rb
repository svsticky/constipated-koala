class ShowParticipantsActivityOption < ActiveRecord::Migration[6.0]
  def change
    add_column :activities, :show_participants, :boolean, default: true
  end
end
