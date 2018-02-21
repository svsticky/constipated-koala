class CreateStudies < ActiveRecord::Migration[4.2]
  def change
    create_table :studies do |t|
      t.string :name
      t.string :code
    end

    change_table :educations do |t|
      t.belongs_to :study
      t.remove :name_id
    end
  end
end
