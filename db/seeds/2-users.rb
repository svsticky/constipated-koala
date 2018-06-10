# Creating login accounts
puts '-- Creating users'
User.transaction do
  Admin.create(
    email:      'dev@svsticky.nl',
    password:   'sticky123',
    skip_confirmation: true
  )
  puts '   -> dev@sticky.nl (admin)'

  Member.all.sample(6).each do |member|
    user = User.new(
      email:       member.email,
      password:    'sticky123',
      credentials: member
    )

    user.skip_confirmation!
    user.save!

    puts "   -> #{ user.email } (member)"
  end
end
