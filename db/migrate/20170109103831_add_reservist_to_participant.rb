class AddReservistToParticipant < ActiveRecord::Migration
  def change
    add_column :participants, :reservist, :boolean, default: false
  end
end
