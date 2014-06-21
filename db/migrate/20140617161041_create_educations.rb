class CreateEducations < ActiveRecord::Migration
  def change
    create_table :educations do |t|
      t.belongs_to :member
      
      t.column :study, :integer
      t.date :start_date
      t.date :end_date

      t.timestamps
    end
  end
end