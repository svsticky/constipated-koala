class CreateCalendars < ActiveRecord::Migration[5.1]
  def change
    create_table :calendars do |t|
      t.integer :member_id
      t.string :calendar_hash
    end
  end
end
