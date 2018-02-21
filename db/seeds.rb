# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
# encoding: UTF-8

require 'faker'

Faker::Config.locale = :nl
puts '-- Populate the database with default configuration'

# Default values required for educations
puts 'Creating studies'
Study.create(
  id:      1,
  code:    'INCA',
  masters: false
)
Study.create(
  id:      2,
  code:    'INKU',
  masters: false
)
Study.create(
  id:      3,
  code:    'GT',
  masters: false
)
Study.create(
  id:      4,
  code:    'COSC',
  masters: true
)
Study.create(
  id:      5,
  code:    'MBIM',
  masters: true
)
Study.create(
  id:      6,
  code:    'AINM',
  masters: true
)
Study.create(
  id:      7,
  code:    'GMTE',
  masters: true
)

# Create one board which by default is not selectable in the app
puts 'Creating board group'
Group.create(
  name:       'Bestuur',
  category:   1,
  created_at: Faker::Date.between(3.years.ago, 2.years.ago)
)

puts 'Creating membership activity'
Activity.create(
  name:          'Lidmaatschap',
  price:         7.5,
  start_date:    Faker::Date.between(30.days.ago, 7.days.ago),
  is_enrollable: false,
  is_masters:    false,
  is_viewable:   false,
  is_alcoholic:  false,
  is_freshmans:  false
)

# Seeds not working on CI
exit unless Rails.env.development? || Rails.env.staging?

puts 'Creating products'
3.times do
  # Create a few food products
  CheckoutProduct.create!(
    name:                  Faker::Food.unique.dish,
    category:              Faker::Number.between(2, 4),
    price:                 Faker::Number.between(0.50, 4.0),
    skip_image_validation: true
  )

  # Create a few alcoholic products
  CheckoutProduct.create(
    name:                  Faker::Beer.name,
    category:              5,
    price:                 Faker::Number.between(1.0, 3.0),
    skip_image_validation: true
  )
end

puts 'Creating admin: dev@svsticky.nl, sticky123'
Admin.create!(
  email:             'dev@svsticky.nl',
  password:          'sticky123',
  skip_confirmation: true
)

puts 'Creating test user: test@svsticky.nl, sticky123'
test_member = Member.create(
  first_name:   'Sticky',
  last_name:    'Tester',
  address:      Faker::Address.street_name,
  house_number: Faker::Address.building_number,
  postal_code:  Faker::Address.postcode,
  city:         Faker::Address.city,
  phone_number: Faker::Base.numerify('+316########'),
  email:        Faker::Internet.safe_email('Sticky' + '.' + 'Tester'),
  gender:       ['m', 'f'].sample,
  student_id:   "F#{ Faker::Number.number(6) }",
  birth_date:   Faker::Date.between(28.years.ago, 16.years.ago),
  join_date:    Faker::Date.between(6.years.ago, Date.today),
  comments:     (Faker::Number.between(1, 10) < 3 ? Faker::Hacker.say_something_smart : nil)
)
test_user = User.new(
  email:       'test@svsticky.nl',
  password:    'sticky123',
  credentials: test_member
)
test_user.skip_confirmation!
test_user.save!

puts 'Create Education for test user'
Education.create(
  study: Study.first,
  member: test_member
)

# Create 60 members and their studies
puts 'Creating members'
60.times do
  first_name = Faker::Name.first_name
  last_name  = Faker::Name.last_name

  Member.transaction do
    (member = Member.create(
      first_name:   first_name,
      infix:        (Faker::Number.between(1, 10) > 7 ? Faker::Name.tussenvoegsel : ' '),
      last_name:    last_name,
      address:      Faker::Address.street_name,
      house_number: Faker::Address.building_number,
      postal_code:  Faker::Address.postcode,
      city:         Faker::Address.city,
      phone_number: Faker::Base.numerify('+316########'),
      email:        Faker::Internet.safe_email(first_name + '.' + last_name),
      gender:       ['m', 'f'].sample,
      student_id:   "F#{ Faker::Number.number(6) }",
      birth_date:   Faker::Date.between(28.years.ago, 16.years.ago),
      join_date:    Faker::Date.between(6.years.ago, Date.today),
      comments:     (Faker::Boolean.boolean(0.3) ? Faker::Hacker.say_something_smart : nil)
    ) and puts "   -> #{ member.name } (#{ member.student_id })")
  end
end

# Commit transaction because we need the member ids
Member.connection.commit_db_transaction

puts 'Creating balances, cards and educations'
Member.all.each do |member|
  checkout_balance = nil
  CheckoutBalance.transaction do
    checkout_balance = CheckoutBalance.create(
      member_id: member.id
    )
  end

  CheckoutCard.transaction do
    Faker::Number.between(1, 2).times do
      CheckoutCard.create(
        uuid:                Faker::Number.hexadecimal(8),
        active:              1,
        member_id:           member.id,
        checkout_balance_id: checkout_balance.id
      )
    end
  end

  Faker::Number.between(1, 3).times do
    # because of the [member, study, start_date] key this goes wrong often
    suppress(ActiveRecord::RecordNotUnique) do
      status     = Faker::Number.between(0, 2)
      start_date = Faker::Date.between(member.join_date, Date.today)
      end_date   = (status > 0 ? Faker::Date.between(start_date, Date.today) : nil)

      Education.create(
        member_id:  member.id,
        study_id:   Study.all.sample,
        start_date: start_date,
        end_date:   end_date,
        status:     status
      )
    end
  end
end

CheckoutBalance.connection.commit_db_transaction
CheckoutCard.connection.commit_db_transaction

puts 'Creating checkout transactions'
Member.all.each do |member|
  member.checkout_cards.each do |checkout_card|
    checkout_transactions = []
    Faker::Number.between(0, 10).times do
      checkout_products = CheckoutProduct.all
      checkout_products.reject(&:liquor?) if member.underage?
      checkout_transactions.push(
        CheckoutTransaction.new(
          checkout_card_id:            checkout_card.id,
          items:                       checkout_products.sample(Faker::Number.between(1, 3)).map(&:id),
          payment_method:              %w[Gepind Contant Verkoop].sample,
          created_at:                  Faker::Date.backward(365 * (Date.today - member.join_date)),
          skip_liquor_time_validation: true
        )
      )
    end
  end
end

# Create committees
puts 'Creating committees'
6.times do
  group = Group.create(
    name:       Faker::Team.name,
    category:   2,
    created_at: Faker::Date.between(3.years.ago, Date.today)
  )

  8.times do
    member   = Member.all.sample
    position = Faker::Boolean.boolean(0.5) ? group.positions.sample : nil

    next if member.nil?

    suppress(ActiveRecord::RecordNotUnique) do
      GroupMember.create(
        member:   member,
        group:    group,
        year:     Faker::Date.between([member.join_date, group.created_at].max, Date.today).study_year,
        position: position
      )
    end
  end
end

# Create 20 activities and the participants
puts 'Creating activities'
start_dates = []
20.times do
  start_dates.push(Faker::Date.between(DateTime.now, 3.months.from_now))
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
  enrollable = Faker::Boolean.boolean(0.5)

  participant_limit = enrollable && Faker::Boolean.boolean(0.5) ? Faker::Number.between(2, 18) : nil

  end_date = multiday ? Faker::Date.between(start_date + 1.day, start_date + 7.days) : nil

  if all_day
    start_time, end_time = nil
  else
    start_time = Faker::Time.between(start_date, start_date)
    end_time = if end_date.nil?
                 rand(start_time..(start_date + 1.day).to_time)
               else
                 rand(end_date..(end_date + 1.day))
               end
  end

  notes = Faker::Boolean.boolean(0.2) ? Faker::Lorem.words(Faker::Number.between(1, 5)).join(' ') : nil

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
    is_masters:        Faker::Boolean.boolean(0.2),
    is_viewable:       Faker::Boolean.boolean(0.9),
    is_alcoholic:      Faker::Boolean.boolean(0.2),
    participant_limit: participant_limit,
    location:          Faker::Lorem.words(Faker::Number.between(1, 3)).join(' '),
    notes:             notes,
    notes_mandatory:   notes.nil? ? Faker::Boolean.boolean(0.2) : false,
    notes_public:      notes.nil? ? Faker::Boolean.boolean(0.6) : true,
    is_freshmans:      Faker::Boolean.boolean(0.2)
  )

  next unless enrollable

  participant_count = Faker::Number.between(0, 20)
  members = Member.all.sample(participant_count)
  members.each do |member|
    reservist = enrollable && !participant_limit.nil? && (activity.participants.count >= participant_limit)

    notes = nil
    if !activity.notes.nil? && (activity.notes_mandatory || Faker::Boolean.boolean(0.3))
      notes = Faker::Lorem.words(Faker::Number.between(1, 3)).join(' ')
    end

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
