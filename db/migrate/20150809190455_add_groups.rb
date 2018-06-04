#:nodoc:
class AddGroups < ActiveRecord::Migration[4.2]
  def change
    create_table :groups do |t|
      t.string :name

      t.integer :category
      t.text :comments

      t.timestamps
    end

    create_table :group_members do |t|
      t.belongs_to :member
      t.belongs_to :group

      t.integer :year
      t.string :position

      t.timestamps
    end

    add_index :group_members, [:member_id, :group_id, :year], :unique => true

    add_column :activities, :organized_by, :integer
  end
end
