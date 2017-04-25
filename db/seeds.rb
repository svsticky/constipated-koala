# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
# encoding: UTF-8

require 'faker'

Faker::Config.locale = :nl
puts '-- Populate the database with default configuration'

# Default values required for educations
Study.create(
  id:             1,
  code:           'INCA',
  masters:        false
)
Study.create(
  id:             2,
  code:           'INKU',
  masters:        false
)
Study.create(
  id:             3,
  code:           'GT',
  masters:        false
)
Study.create(
  id:             4,
  code:           'COSC',
  masters:        true
)
Study.create(
  id:             5,
  code:           'MBIM',
  masters:        true
)
Study.create(
  id:             6,
  code:           'AINM',
  masters:        true
)
Study.create(
  id:             7,
  code:           'GMTE',
  masters:        true
)

# Create one board which by default is not selectable in the app
Group.create(
  name:       'Bestuur',
  category:   1,
  created_at: Faker::Date.between(3.years.ago, 2.years.ago)
)

activity = Activity.create(
  name:         'Lidmaatschap',
  price:        7.5,
  start_date:   Faker::Date.between(30.days.ago, 7.days.ago)
)

# Seeds not working on CI
exit unless Rails.env.development?

# Create 60 members and their studies
puts '-- Populate the database using Faker'
60.times do
  first_name = Faker::Name.first_name
  last_name = Faker::Name.last_name

  member = Member.create(
    first_name:   first_name,
    infix:        (Faker::Number.between(1, 10) > 7 ? Faker::Name.tussenvoegsel : ' '),
    last_name:    last_name,
    address:      Faker::Address.street_name,
    house_number: Faker::Address.building_number,
    postal_code:  Faker::Address.postcode,
    city:         Faker::Address.city,
    phone_number: Faker::PhoneNumber.phone_number,
    email:        Faker::Internet.safe_email(first_name + '.' + last_name),
    gender:       ['m', 'f'].sample,
    student_id:   "F#{Faker::Number.number(6)}",
    birth_date:   Faker::Date.between(28.years.ago, 18.years.ago),
    join_date:    Faker::Date.between(3.years.ago, Date.today),
    comments:     (Faker::Number.between(1, 10) < 3 ? Faker::Hacker.say_something_smart : NIL)
  ) and puts "   -> #{member.name} (#{member.student_id})"

  Faker::Number.between(1, 3).times do
    # because of the [member, study, start_date] key this goes wrong often
    suppress(ActiveRecord::RecordNotUnique) do
      status = Faker::Number.between(0, 2)
      start_date = Faker::Date.between(member.join_date, Date.today)
      end_date = (status > 0 ? Faker::Date.between(start_date, Date.today) : NIL)

      Education.create(
        member_id:    member.id,
        study_id:     Faker::Number.between(1, Study.count),
        start_date:   start_date,
        end_date:     end_date,
        status:       status
      )
    end
  end
end


# Create groups
6.times do
  group = Group.create(
    name:       Faker::Team.name,
    category:   2,
    created_at: Faker::Date.between(3.years.ago, Date.today)
  )

  8.times do
    member = Member.find_by_id(Faker::Number.between(1, Member.count))
    position = (Faker::Number.between(1, 10) < 5 ? group.positions[ Faker::Number.between(1, group.positions.count) ] : NIL)

    next if member.nil?

    suppress(ActiveRecord::RecordNotUnique) do
      GroupMember.create(
        member:    member,
        group:     group,
        year:      Faker::Date.between( [member.join_date, group.created_at].max, Date.today ).study_year,
        position:  position
      )
    end
  end
end


# Create 20 activities and the participants
15.times do
  start_date = Faker::Date.between(2.years.ago, 1.years.from_now)
  start_time = nil
  end_date = nil
  end_time = nil

  # We generate four types of activities:
  # 1: Multiple days, all day
  # 2: Single day, all day
  # 3: Single day, with start and end time
  # 4: Multiple days, with start and end time
  multiday = Faker::Boolean.boolean
  all_day = Faker::Boolean.boolean
  enrollable = Faker::Boolean.boolean(0.3)

  participant_limit = nil
  if enrollable
    if Faker::Boolean.boolean(0.5)
      participant_limit = Faker::Number.between(2, 18)
    end
  end

  end_date = Faker::Date.between(start_date, 1.years.from_now) if multiday

  if not all_day
    start_sec = Faker::Number.between(0, 86400)
    start_time = Time.at(start_sec)
    end_time = Time.at(Faker::Number.between(start_sec, 86400))
  end

  activity = Activity.create(
    name:         Faker::Hacker.ingverb.capitalize,
    price:        Faker::Commerce.price/5,
    start_date:   start_date,
    start_time:   start_time,
    end_date:     end_date,
    end_time:     end_time,
    organized_by: (Faker::Number.between(1, 10) < 4 ? Group.find_by_id(Faker::Number.between(1, Group.count)) : NIL),
    is_enrollable: enrollable
  )

  20.times do
    reservist = false
    if enrollable
      reservist = true if participant_limit and activity.participants.count > participant_limit
    end

    # because of the [member, activity] key this also conflicts often
    suppress(ActiveRecord::RecordNotUnique) do
      Participant.create(
        member:       Member.find_by_id(Faker::Number.between(1, Member.count)),
        reservist:    reservist,
        activity:     activity,
        price:        (Faker::Number.between(1, 10) < 2 ? Faker::Commerce.price/5 : NIL),
        paid:         (Faker::Number.between(1, 10) < 4 ? true : false) # if price is 0 than the paid attribute is not used
      )
    end
  end
end
