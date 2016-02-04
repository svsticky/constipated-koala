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
  code:           'WISK',
  masters:        false
)
Study.create(
  id:             7,
  code:           'AINM',
  masters:        true
)
Study.create(
  id:             8,
  code:           'GMTE',
  masters:        true
)


# Default configuration
UserConfiguration.create(
  abbreviation:   'allowed_email_pattern',
  name:           'Toegestaande e-mailadressen',
  description:    'Defineer de toegestaande e-mailadressen met reguliere expressie',
  value:          '/[A-Za-z0-9.+-_]+@(?![A-Za-z0-9.+-_]*\.?uu\.nl)([A-Za-z0-9.+-_]+\.[A-Za-z.]+)/',
  config_type:    UserConfiguration.config_types[:string]
) and puts '   -> ENV[\'ALLOWED_EMAIL_PATTERN\']'

UserConfiguration.create(
  abbreviation:   'student_id_required',
  name:           'Studentnummer verplicht',
  description:    'Maak het studentnummer verplicht in /\F?\d{6,7}/ formaat',
  value:          'true',
  config_type:    UserConfiguration.config_types[:boolean]
) and puts '   -> ENV[\'STUDENT_ID_REQUIRED\']'

UserConfiguration.create(
  abbreviation:   'student_id_elfproef',
  name:           'Elfproef studentnummer',
  description:    'Controleer het studentnummer met de elfproef als het geen /\F\d{6}/ is.',
  value:          'false',
  config_type:    UserConfiguration.config_types[:boolean]
) and puts '   -> ENV[\'STUDENT_ID_ELFPROEF\']'

UserConfiguration.create(
  abbreviation:   'additional_committee_positions',
  name:           'Extra commissierollen',
  description:    'Rollen die naast voorzitter, penningmeester, en bestuurslid worden toegevoegd aan alle commissies.',
  value:          '["fotograaf"]',
  config_type:    UserConfiguration.config_types[:array]
) and puts '   -> ENV[\'ADDITIONAL_COMMITTEE_POSITIONS\']'

# Create one board which by default is not selectable in the app
Group.create(
  name:       'Bestuur',
  category:   1,
  created_at: Faker::Date.between(3.years.ago, 2.years.ago)
)

exit if Rails.env == 'production'

# Seeds not working on CI
exit if Rails.env == 'test'

# Load the user_settings just set
puts '-- Load user configuration for environment variables'
load 'config/initializers/load_settings.rb' and puts '   -> config/initializers/load_settings.rb'

# Create 60 members and their studies
puts '-- Populate the database using Faker'
60.times do
  first_name = Faker::Name.first_name
  last_name = Faker::Name.last_name

  member = Member.create(
    first_name:   first_name,
    infix:        (Faker::Number.between(1, 10) > 7 ? Faker::Name.tussenvoegsel : NIL),
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


# Create groups with on board.
6.times do
  group = Group.create(
    name:       Faker::Team.name,
    category:   3,
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
  end_date = (Faker::Number.between(1, 10) < 2 ? Faker::Date.between(start_date, 1.years.from_now) : NIL)

  activity = Activity.create(
    name:         Faker::Hacker.ingverb.capitalize,
    price:        Faker::Commerce.price/5,
    start_date:   start_date,
    end_date:     end_date,
    organized_by: (Faker::Number.between(1, 10) < 4 ? Group.find_by_id(Faker::Number.between(1, Group.count)) : NIL)
  )

  20.times do
    # because of the [member, activity] key this also conflicts often
    suppress(ActiveRecord::RecordNotUnique) do
      Participant.create(
        member:       Member.find_by_id(Faker::Number.between(1, Member.count)),
        activity:     activity,
        price:        (Faker::Number.between(1, 10) < 2 ? Faker::Commerce.price/5 : NIL),
        paid:         (Faker::Number.between(1, 10) < 4 ? true : false) # if price is 0 than the paid attribute is not used
      )
    end
  end
end
