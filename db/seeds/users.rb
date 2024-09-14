require Rails.root.join('db', 'seeds', 'members.rb')

# Creating login accounts
puts '-- Creating users'

dev = Admin.create(
  email: 'dev@svsticky.nl',
  password: 'sticky123'
)

puts "   [#{ dev.valid? ? ' Ok ' : 'Fail' }] dev@sticky.nl (admin)"
dev.errors.objects.each do |error|
  puts "          > #{error.full_message}"
end

martijn = Admin.create(
  email: 'martijn@svsticky.nl',
  password: 'sticky123',

  first_name: 'Martijn',
  last_name: 'Casteel',
  signature: 'Martijn'
)

puts "   [#{ martijn.valid? ? ' Ok ' : 'Fail' }] martijn@sticky.nl (admin)"
martijn.errors.objects.each do |error|
  puts "          > #{error.full_message}"
end

# create actual members, but give the first member test@svsticky.nl
member = Member.joins(:educations).where(educations: { status: 0 }).first
member.update(email: 'test@svsticky.nl')

user = User.new(
  email: member.email,
  password: 'sticky123',
  credentials: member,
  language: Faker::Number.within(range: 0..1)
)

user.skip_confirmation!
user.save!

puts "   [#{ user.valid? ? ' Ok ' : 'Fail' }] #{ user.email } (member)"
user.errors.objects.each do |error|
  puts "          > #{error.full_message}"
end
