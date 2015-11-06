collection @groups
attributes :id, :name, :category

child :group_members => :members do
  node :id do |group_member|
    group_member.member.id
  end

  attributes :name, :position
end
