class CreateMembers < ActiveRecord::Migration
  def change
    create_table :members do |t|
      t.string :first_name
      t.string :infix
      t.string :last_name
      t.string :address
      t.string :house_number
      t.string :postal_code
      t.string :city
      t.string :phone_number
      t.string :email
      t.string :gender, limit: 1
      t.integer :student_id
      t.date :birth_date
      t.date :join_date
      t.text :comments

      t.timestamps
    end
  end
end
