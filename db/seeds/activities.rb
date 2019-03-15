require Rails.root.join('db', 'seeds', 'members.rb')

# Create 20 activities and the participants
puts '-- Creating activities'

dates = []

20.times do
  dates << Faker::Time.between(Time.now, 3.months.from_now, :morning)
  dates << Faker::Time.between(2.years.ago, Date.today, :morning)
end

dates.each do |start_date|
  # We generate four types of activities:
  # 1: Multiple days, all day
  # 2: Single day, all day
  # 3: Multiple days, with start and end time
  # 4: Single day, with start and end time
  @multiple   = Faker::Boolean.boolean
  @single     = !@multiple
  @entire     = Faker::Boolean.boolean
  @part       = !@entire

  viewable   = Faker::Boolean.boolean(0.9)
  enrollable = viewable ? Faker::Boolean.boolean(0.5) : false
  notes = Faker::Boolean.boolean(0.2) ? Faker::Lorem.question : nil

  activity = Activity.create(
    name:              Faker::Hacker.ingverb.capitalize,
    price:             Faker::Commerce.price / 5,

    # TODO: use date as timefield as well in model, perhaps add boolean for all day
    start_date:        start_date,
    start_time:        @part ? start_date.to_time : nil,

    end_date:          @multiple ? Faker::Date.between(start_date + 1.day, start_date + 7.days) : nil,
    end_time:          @part ? Faker::Time.between(start_date, start_date, :evening) : nil,

    location:          Faker::FamilyGuy.location,
    organized_by:      Faker::Boolean.boolean(0.8) ? Group.all.sample : nil,
    description:       Faker::Lorem.paragraph(5),

    is_enrollable:     enrollable,
    is_masters:        Faker::Boolean.boolean(0.2),
    is_viewable:       viewable,
    is_alcoholic:      Faker::Boolean.boolean(0.2),
    is_freshmans:      Faker::Boolean.boolean(0.2),

    participant_limit: enrollable && Faker::Boolean.boolean(0.5) ? Faker::Number.between(2, 18) : nil,

    notes:             notes,
    notes_mandatory:   notes.nil? ? Faker::Boolean.boolean(0.2) : false,
    notes_public:      notes.nil? ? Faker::Boolean.boolean(0.6) : true
  )

  puts("   -> #{ activity.name } (#{ start_date })")

  # activity.poster.attach(io: File.open('public/poster-example.pdf'), filename: 'poster-example.pdf', content_type: 'application/pdf')

  next unless enrollable

  # easily filter out underaged
  eligible = Member.where('birth_date < ?', activity.start_date - 18.years).all if activity.is_alcoholic
  eligible = Member.all unless activity.is_alcoholic

  # select freshmans or masters
  eligible = eligible.select(&:freshman?) if activity.is_freshmans
  eligible = eligible.select(&:masters?) if activity.is_masters

  response = !activity.notes.nil? && (activity.notes_mandatory || Faker::Boolean.boolean(0.3)) ? Faker::Measurement.height : nil

  eligible.sample(Faker::Number.between(20, 20)).each do |member|
    Participant.create(
      member:     member,
      activity:   activity,
      price:      (Faker::Boolean.boolean(0.2) ? Faker::Commerce.price / 5 : nil),
      paid:       Faker::Boolean.boolean(0.4), # if price is 0 then the paid attribute is not used
      notes:      response
    )
  end
end
