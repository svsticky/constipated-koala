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
activity = Activity.create(
  name:       'Lidmaatschap',
  price:      7.5,
  start_date: Faker::Date.between(30.days.ago, 7.days.ago)
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
    storage_stock:         Faker::Number.between(0, 200),
    chamber_stock:         Faker::Number.between(0, 50),
    skip_image_validation: true
  )

  # Create a few alcoholic products
  CheckoutProduct.create(
    name:                  Faker::Beer.name,
    category:              5,
    price:                 Faker::Number.between(1.0, 3.0),
    storage_stock:         Faker::Number.between(0, 200),
    chamber_stock:         Faker::Number.between(0, 50),
    skip_image_validation: true
  )
end

# Create 60 members and their studies
puts 'Creating members'
60.times do
  first_name = Faker::Name.first_name
  last_name  = Faker::Name.last_name

  Member.transaction do
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
      birth_date:   Faker::Date.between(28.years.ago, 16.years.ago),
      join_date:    Faker::Date.between(6.years.ago, Date.today),
      comments:     (Faker::Number.between(1, 10) < 3 ? Faker::Hacker.say_something_smart : nil)
    ) and puts "   -> #{member.name} (#{member.student_id})"
  end
end

# Commit transaction because we need the member ids
Member.connection.commit_db_transaction

puts 'Creating balances, cards and educations'
Member.all.each do |member|
  checkout_balance = nil
  CheckoutBalance.transaction do
    checkout_balance = CheckoutBalance.create(
      balance:   Faker::Number.between(130.00, 150.00),
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
        study_id:   Faker::Number.between(1, Study.count),
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
    Faker::Number.between(0, 10).times do
      checkout_products = CheckoutProduct.all
      if member.is_underage?
        checkout_products.reject { |product| product.liquor? }
      end
      CheckoutTransaction.create(
        checkout_card_id: checkout_card.id,
        items:            checkout_products.sample(Faker::Number.between(1, 3)).map { |product| product.id },
        payment_method:   %w[Gepind Contant Verkoop].sample,
        created_at:       Faker::Date.backward,
        skip_liquor_time_validation: true
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
    member   = Member.find_by_id(Faker::Number.between(1, Member.count))
    position = (Faker::Number.between(1, 10) < 5 ? group.positions[Faker::Number.between(1, group.positions.count)] : nil)

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
15.times do
  start_date = Faker::Date.between(2.years.ago, 1.years.from_now)
  start_time = nil
  end_date   = nil
  end_time   = nil

  # We generate four types of activities:
  # 1: Multiple days, all day
  # 2: Single day, all day
  # 3: Single day, with start and end time
  # 4: Multiple days, with start and end time
  multiday   = Faker::Boolean.boolean
  all_day    = Faker::Boolean.boolean
  enrollable = Faker::Boolean.boolean(0.3)

  participant_limit = nil
  if enrollable
    if Faker::Boolean.boolean(0.5)
      participant_limit = Faker::Number.between(2, 18)
    end
  end

  end_date = Faker::Date.between(start_date, 1.years.from_now) if multiday

  if not all_day
    start_sec  = Faker::Number.between(0, 86400)
    start_time = Time.at(start_sec)
    end_time   = Time.at(Faker::Number.between(start_sec, 86400))
  end

  activity = Activity.create(
    name:          Faker::Hacker.ingverb.capitalize,
    price:         Faker::Commerce.price/5,
    start_date:    start_date,
    start_time:    start_time,
    end_date:      end_date,
    end_time:      end_time,
    organized_by:  (Faker::Number.between(1, 10) < 4 ? Group.find_by_id(Faker::Number.between(1, Group.count)) : nil),
    is_enrollable: enrollable,
    is_masters:    (Faker::Boolean.boolean(0.3))
  )

  20.times do
    reservist = false
    if enrollable
      reservist = true if participant_limit and activity.participants.count > participant_limit
    end

    # because of the [member, activity] key this also conflicts often
    suppress(ActiveRecord::RecordNotUnique) do
      Participant.create(
        member:    Member.find_by_id(Faker::Number.between(1, Member.count)),
        reservist: reservist,
        activity:  activity,
        price:     (Faker::Number.between(1, 10) < 2 ? Faker::Commerce.price/5 : nil),
        paid:      (Faker::Number.between(1, 10) < 4 ? true : false) # if price is 0 than the paid attribute is not used
      )
    end
  end
end
