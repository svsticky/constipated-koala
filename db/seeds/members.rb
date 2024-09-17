# Create 60 members and their studies
puts '-- Creating members'
60.times do
  first_name = Faker::Name.first_name
  last_name = Faker::Name.last_name

  member = Member.create(
    first_name: first_name,
    infix: (Faker::Number.within(range: 1..10) > 7 ? Faker::Name.tussenvoegsel : ' '),
    last_name: last_name,
    address: Faker::Address.street_name,
    house_number: Faker::Address.building_number,
    postal_code: Faker::Address.postcode,
    city: Faker::Address.city,
    phone_number: Faker::Base.numerify('+316########'),
    emergency_phone_number: Faker::Base.numerify('+316########'),
    email: Faker::Internet.safe_email(name: (first_name + '.' + last_name).parameterize),
    student_id: "F#{ Faker::Number.number(digits: 6) }",
    birth_date: Faker::Date.between(from: 28.years.ago, to: 16.years.ago),
    join_date: Faker::Date.between(from: 6.years.ago, to: Date.today),
    comments: (Faker::Boolean.boolean(true_ratio: 0.3) ? Faker::Hacker.say_something_smart : nil)
    calendar_id: Faker::Internet.uuid
  )

  puts "   [#{ member.valid? ? ' Ok ' : 'Fail' }] #{ member.name } (#{ member.student_id })"
  member.errors.objects.each do |error|
    puts "          > #{error.full_message}"
  end
end

puts '-- Creating educations'
Member.all.each do |member|
  Faker::Number.within(range: 1..3).times do
    # because of the [member, study, start_date] key this goes wrong often
    suppress(ActiveRecord::RecordNotUnique) do
      status = Faker::Number.within(range: 0..2)
      start_date = Faker::Date.between(from: member.join_date, to: Date.today)
      end_date = (status > 0 ? Faker::Date.between(from: start_date, to: Date.today) : nil)

      education = Education.create(
        member_id: member.id,
        study_id: Study.all.sample.id,
        start_date: start_date,
        end_date: end_date,
        status: status
      )

      puts "   [#{ education.valid? ? ' Ok ' : 'Fail' }] #{ education.study_id } for #{ education.member_id }"
      education.errors.objects.each do |error|
        puts "          > #{error.full_message}"
      end
    end
  end
end
