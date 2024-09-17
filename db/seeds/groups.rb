require Rails.root.join('db', 'seeds', 'members.rb')

# Create committees
puts '-- Creating committees'
8.times do
  group = Group.create(
    name: Faker::Team.unique.name,
    category: 2,
    created_at: Faker::Date.between(from: 3.years.ago, to: Date.today - 1.year)
  )

  puts "   [#{ group.valid? ? ' Ok ' : 'Fail' }] #{ group.name } (#{ group.created_at.study_year }-#{ Date.today.study_year })"
  group.errors.objects.each do |error|
    puts "          > #{error.full_message}"
  end

  Member.all.sample(10).each do |member|
    group_member = GroupMember.create(
      member: member,
      group: group,
      year: Faker::Date.between(from: [member.join_date, group.created_at].max, to: Date.today).study_year,
      position: Faker::Boolean.boolean(true_ratio: 0.5) ? group.positions.sample : nil
    )

    puts "   [#{ group_member.valid? ? ' Ok ' : 'Fail' }] + #{ group_member.member.first_name } #{ group_member.member.last_name }"
    group_member.errors.objects.each do |error|
      puts "          > #{error.full_message}"
    end
  end
end
