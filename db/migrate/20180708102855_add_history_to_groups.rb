class AddHistoryToGroups < ActiveRecord::Migration[5.2]
  def up
    # return

    # create file for migration
    if ActiveRecord::Base.connection.column_exists?(:group_members, :year)
      # list the groups that should be created
      groups = GroupMember.pluck(:group_id, :year).uniq.map do |group, year|
        {id: group, year: year, group_members: GroupMember.where(:group => group, :year => year).pluck(:id)}
      end
    end

    add_column :groups, :group_name, :string
    add_column :groups, :year, :integer
    remove_index :group_members, column: [:member_id, :group_id, :year]

    if ActiveRecord::Base.connection.column_exists?(:group_members, :year)
      groups.each do |item|
        group = Group.find_by_id(item[:id])

        # reuse this group if not yet done
        if group.year.nil?
          group.update(year: item[:year], group_name: group.name)
          next
        end

        group = group.dup
        group.year = item[:year]
        group.save

        GroupMember.where(:id => item[:group_members]).update(group_id: group.id)
      end

      remove_column :group_members, :year
      add_index :group_members, [:member_id, :group_id], unique: true
    end
  end

  def down
    # rollback can't be done
    raise ActiveRecord::IrreversibleMigration
  end
end
