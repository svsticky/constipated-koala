class CreateParticipantTransactions < ActiveRecord::Migration[6.0]
  def change
    create_table :participant_transactions do |t|
      t.belongs_to :member

      t.string :activity_id
      t.timestamps
    end
  end
end
