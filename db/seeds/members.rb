# Create 60 members and their studies
puts '-- Creating members'
60.times do
  first_name = Faker::Name.first_name
  last_name  = Faker::Name.last_name

  member = Member.create(
    first_name:   first_name,
    infix:        (Faker::Number.between(1, 10) > 7 ? Faker::Name.tussenvoegsel : ' '),
    last_name:    last_name,
    address:      Faker::Address.street_name,
    house_number: Faker::Address.building_number,
    postal_code:  Faker::Address.postcode,
    city:         Faker::Address.city,
    phone_number: Faker::Base.numerify('+316########'),
    email:        Faker::Internet.safe_email(first_name + '.' + last_name),
    student_id:   "F#{ Faker::Number.number(6) }",
    birth_date:   Faker::Date.between(28.years.ago, 16.years.ago),
    join_date:    Faker::Date.between(6.years.ago, Date.today),
    comments:     (Faker::Boolean.boolean(0.3) ? Faker::Hacker.say_something_smart : nil)
  )

  puts("   -> #{ member.name } (#{ member.student_id })")
end

puts '-- Creating educations'
Member.all.each do |member|
  Faker::Number.between(1, 3).times do
    # because of the [member, study, start_date] key this goes wrong often
    suppress(ActiveRecord::RecordNotUnique) do
      status     = Faker::Number.between(0, 2)
      start_date = Faker::Date.between(member.join_date, Date.today)
      end_date   = (status > 0 ? Faker::Date.between(start_date, Date.today) : nil)

      Education.create(
        member_id:  member.id,
        study_id:   Study.all.sample.id,
        start_date: start_date,
        end_date:   end_date,
        status:     status
      )
    end
  end
end
