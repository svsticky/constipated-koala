require Rails.root.join('db', 'seeds', 'members.rb')

# Create committees
puts '-- Creating committees'
8.times do
  group = Group.create(
    name:       Faker::Team.unique.name,
    category:   2,
    created_at: Faker::Date.between(3.years.ago, Date.today - 1.year)
  )

  Member.all.sample(10).each do |member|
    GroupMember.create(
      member:   member,
      group:    group,
      year:     Faker::Date.between([member.join_date, group.created_at].max, Date.today).study_year,
      position: Faker::Boolean.boolean(0.5) ? group.positions.sample : nil
    )
  end

  puts("   -> #{ group.name } (#{ group.created_at.study_year }-#{ Date.today.study_year })")
end
