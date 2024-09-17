require Rails.root.join('db', 'seeds', 'members.rb')
require Rails.root.join('db', 'seeds', 'activities.rb')

puts '-- Creating member transactions'

Member.all.sample(30).each do |member|
  15.times do
    status = Faker::Number.within(range: 0..2)
    payment_type = Faker::Number.within(range: 0.0..1.0) < 0.5 ? 0 : 3

    participants = Participant.where(member: member).where.not(activity: [nil, 1]).select { |p| p.currency != nil }.sample(Faker::Number.within(range: 1..6))

    participants.map { |p| p.update(paid: true) }

    amount = 0
    participants.map { |p| amount += p.currency }

    transaction_id = participants.map{|p| p.activity.id}

    description = "Activiteiten - #{transaction_id}"

    payment = Payment.create(member: member,
                             transaction_type: 1,
                             payment_type: payment_type,
                             transaction_id: transaction_id,
                             description: description,
                             amount: amount,
                             status: status,
                             trxid: Digest::MD5.hexdigest(description + Time.now.to_f.to_s),
                             created_at: Faker::Date.between(from: 1.weeks.ago, to: Date.today),
                             message: 'seeding',
                             redirect_uri: ENV['KOALA_DOMAIN']
    )

    puts "   [#{ payment.valid? ? ' Ok ' : 'Fail' }] #{['Failed', 'In progress', 'Successful'][status]} transaction by #{ payment.member.first_name } #{ payment.member.last_name } of #{ payment.amount } for #{ payment.transaction_id } using #{ payment_type == 0 ? "ideal" : "pin" }"
    payment.errors.objects.each do |error|
      puts "          > #{error.full_message}"
    end
  end
end
