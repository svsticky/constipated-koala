object @group
attributes :name, :category

child :group_members => :members do
  node :id do |group_member|
    group_member.member.id
  end

  attributes :name, :position
end

child :activities do
  attributes :id, :name, :start_date, :end_date, :price
end
