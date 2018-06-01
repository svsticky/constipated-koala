#:nodoc:
class AddReservistToParticipant < ActiveRecord::Migration[4.2]
  def change
    add_column :participants, :reservist, :boolean, default: false
  end
end
