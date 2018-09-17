require Rails.root.join('db', 'seeds', 'members.rb')

# Creating login accounts
puts '-- Creating users'
Admin.create(
  email:    'dev@svsticky.nl',
  password: 'sticky123'
)
puts '   -> dev@sticky.nl (admin)'

Admin.create(
  email:      'martijn@svsticky.nl',
  password:   'sticky123',

  first_name: 'Martijn',
  last_name:  'Casteel',
  signature:  'Martijn'
)
puts '   -> martijn@sticky.nl (admin)'

# create actual members, but give the first member test@svsticky.nl
Member.all.sample(6).each_with_index do |member, id|
  member.update(email: 'test@svsticky.nl') if id == 0

  user = User.new(
    email:       member.email,
    password:    'sticky123',
    credentials: member
  )

  user.skip_confirmation!
  user.save!

  puts "   -> #{ user.email } (member)"
end
