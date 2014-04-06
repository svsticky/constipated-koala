# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
require "faker"

Faker::Config.locale = :nl

150.times do
  Member.create(first_name: Faker::Name.first_name,
                infix: '',
                last_name: Faker::Name.last_name,
                address: Faker::Address.street_name,
                house_number: Faker::Address.building_number,
                postal_code: Faker::Address.postcode,
                city: Faker::Address.city,
                phone_number: Faker::PhoneNumber.cell_phone,
                email: Faker::Internet.email,
                gender: ['m', 'f'].sample,
                student_id: Faker::Number.number(7),
                birth_date: Faker::Business.credit_card_expiry_date,
                join_date: Faker::Business.credit_card_expiry_date,
                comments: '')
end
