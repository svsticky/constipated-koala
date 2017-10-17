class AddStatusToEducation < ActiveRecord::Migration[4.2]
  def change
    change_table :studies do |t|
      t.boolean :masters
    end

    change_table :educations do |t|
      t.integer :status
    end

    change_column :educations, :study_id, :integer, :null => false

    add_index :educations, [:member_id, :study_id, :start_date], :unique => true
  end
end