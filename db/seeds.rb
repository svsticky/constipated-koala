# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

require "faker"

Faker::Config.locale = :nl

Admin.create(
  email:                  'martijn.casteel@gmail.com',
  password:               'sticky123',
  password_confirmation:  'sticky123'
)

100.times do
  Member.create(
    first_name:   Faker::Name.first_name,
    infix:        (Random.rand(10) > 7 ? Faker::Name.tussenvoegsel : ''),
    last_name:    Faker::Name.last_name,
    address:      Faker::Address.street_name,
    house_number: Faker::Address.building_number,
    postal_code:  Faker::Address.postcode,
    city:         Faker::Address.city,
    phone_number: Faker::PhoneNumber.phone_number,
    email:        Faker::Internet.email,
    gender:       ['m', 'f'].sample,
    student_id:   Faker::Number.number(7),
    birth_date:   Faker::Business.credit_card_expiry_date,
    join_date:    Faker::Business.credit_card_expiry_date,
    comments:     (Random.rand(10) > 3 ? Faker::Company.catch_phrase : NIL)
  )
end
  
110.times do
  Education.create(
    member:       Member.find(1+ Random.rand(Member.count)),
    study_id:     Random.rand(7), #there are now 0..7 educations
    start_date:   Faker::Business.credit_card_expiry_date,
    end_date:     (Random.rand(10) > 6 ? Faker::Business.credit_card_expiry_date : NIL)
  )
end

12.times do
  Activity.create(
    name:         Faker::Commerce.department,
    price:        Faker::Commerce.price,
    start_date:   Faker::Business.credit_card_expiry_date 
  )
end

# Suppress exception for the unique key [member, activity], daarom ook zo veel..
suppress(Exception) do
  200.times do
    Participant.create(
      member:       Member.find(1+ Random.rand(Member.count)),
      activity:     Activity.find(1+ Random.rand(Activity.count)),
      price:        (Random.rand(10) > 6 ? Faker::Commerce.price : NIL),
      paid:        (Random.rand(10) > 8 ? true : false)
    )
  end
end