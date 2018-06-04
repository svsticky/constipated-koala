#:nodoc:
class CreateTags < ActiveRecord::Migration[4.2]
  def change
    create_table :tags do |t|
      t.belongs_to :member

      t.column :name_id, :integer
      t.timestamps
    end

    add_index :tags, [:member_id, :name_id], :unique => true
  end
end
