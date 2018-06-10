# Create 20 activities and the participants
puts '-- Creating activities'
start_dates = []
20.times do
  start_dates.push(Faker::Date.between(Time.now, 3.months.from_now))
end

40.times do
  start_dates << Faker::Date.between(2.years.ago, Date.today)
end

start_dates.each do |start_date|
  # We generate four types of activities:
  # 1: Multiple days, all day
  # 2: Single day, all day
  # 3: Single day, with start and end time
  # 4: Multiple days, with start and end time
  multiday   = Faker::Boolean.boolean
  all_day    = Faker::Boolean.boolean
  viewable   = Faker::Boolean.boolean(0.9)
  enrollable = viewable ? Faker::Boolean.boolean(0.5) : false

  participant_limit = enrollable && Faker::Boolean.boolean(0.5) ? Faker::Number.between(2, 18) : nil

  end_date = multiday ? Faker::Date.between(start_date + 1.day, start_date + 7.days) : nil

  if all_day
    start_time, end_time = nil
  else
    start_time = Faker::Time.between(start_date, start_date)
    end_time   = if end_date.nil?
                   rand(start_time..(start_date + 1.day).to_time)
                 else
                   rand(end_date..(end_date + 1.day))
                 end
  end

  notes = Faker::Boolean.boolean(0.2) ? Faker::Lorem.words(Faker::Number.between(1, 5)).join(' ') : nil

  is_freshmans = Faker::Boolean.boolean(0.2)
  is_masters   = Faker::Boolean.boolean(0.2)
  is_alcoholic = Faker::Boolean.boolean(0.2)

  activity = Activity.create(
    name:              Faker::Hacker.ingverb.capitalize,
    price:             Faker::Commerce.price / 5,
    start_date:        start_date,
    start_time:        start_time,
    end_date:          end_date,
    end_time:          end_time,
    organized_by:      Faker::Boolean.boolean(0.8) ? Group.all.sample : nil,
    description:       Faker::Lorem.paragraph(5),
    is_enrollable:     enrollable,
    is_masters:        is_masters,
    is_viewable:       viewable,
    is_alcoholic:      is_alcoholic,
    participant_limit: participant_limit,
    location:          Faker::Lorem.words(Faker::Number.between(1, 3)).join(' '),
    notes:             notes,
    notes_mandatory:   notes.nil? ? Faker::Boolean.boolean(0.2) : false,
    notes_public:      notes.nil? ? Faker::Boolean.boolean(0.6) : true,
    is_freshmans:      is_freshmans
  )

  puts("   -> #{ activity.name } (#{activity.start_date})")

  next unless enrollable

  eligible_members = Member.all
  eligible_members = eligible_members.select(&:freshman?) if is_freshmans
  eligible_members = eligible_members.select(&:masters?) if is_masters
  eligible_members = eligible_members.select(&:adult?) if is_alcoholic

  participant_count = Faker::Number.between(0, 20)
  members           = eligible_members.sample(participant_count)
  members.each do |member|
    reservist = enrollable && !participant_limit.nil? && (activity.participants.count >= participant_limit)

    notes = nil
    notes = Faker::Lorem.words(Faker::Number.between(1, 3)).join(' ') if !activity.notes.nil? && (activity.notes_mandatory || Faker::Boolean.boolean(0.3))

    Participant.create(
      member:    member,
      reservist: reservist,
      activity:  activity,
      price:     (Faker::Boolean.boolean(0.2) ? Faker::Commerce.price / 5 : nil),
      paid:      Faker::Boolean.boolean(0.4), # if price is 0 then the paid attribute is not used
      notes: notes
    )
  end
end
