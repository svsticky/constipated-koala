class CreateEducations < ActiveRecord::Migration[4.2]
  def change
    create_table :educations do |t|
      t.belongs_to :member
      
      t.column :name_id, :integer
      t.date :start_date
      t.date :end_date

      t.timestamps
    end
  end
end