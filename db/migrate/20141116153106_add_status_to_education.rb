class AddStatusToEducation < ActiveRecord::Migration
  def change
    change_table :studies do |t|
      t.boolean :masters
    end

    change_table :educations do |t|
      t.integer :status
    end
    
    change_column :educations, :study_id, :integer, :null => false
  end
end