class DropCommitteeId < ActiveRecord::Migration
  def change
    remove_column :activities, :committee_id
  end
end
