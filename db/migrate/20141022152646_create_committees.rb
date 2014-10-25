class CreateCommittees < ActiveRecord::Migration
  def change
    create_table :committees do |t|
      t.string :name
      t.text :comments
      t.timestamps
    end

    create_table :committee_members do |t|
      t.belongs_to :member
      t.belongs_to :committee
      t.text :function
      t.timestamps
    end

    add_index :committee_members, [:member_id, :committee_id], :unique => true

  end
end