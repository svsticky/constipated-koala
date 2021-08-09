require Rails.root.join('db', 'seeds', 'members.rb')
require Rails.root.join('db', 'seeds', 'activities.rb')

puts '-- member transaction creation'

Member.all.sample(30).each do |member|

  15.times do
    transactiontype = Faker::Number.within(range: 0..1)
    paymenttype = Faker::Number.within(range:0..3)
    status = Faker::Number.within(range:0..2)
    if transactiontype == 1 && status == 0
      participants = Participant.where(member:member).where.not(activity:[nil,1]).select{|p| p.currency != nil}.sample(Faker::Number.within(range:1..6))
      participants.map {|p|p.update(paid:true)}
      transaction_id = participants.map{|p| p.activity.id}
      amount = 0
      participants.map{ |p| amount += p.currency}
      status = 2
    else
      transaction_id = [1]
      status = 0 
    end
    description = transactiontype == 0 ? "Mongoose Opwaardering" : "Activiteiten - #{transaction_id}"

    @payment =Payment.create(member: member,
                   transaction_type: transactiontype,
                   payment_type: paymenttype ,
                   transaction_id: transaction_id,
                   description: description,
                   amount: Faker::Number.within(range: 1.0..10.0),
                   status: status,
                   trxid: Digest::MD5.hexdigest(description + Time.now.to_f.to_s),
                   created_at: Faker::Date.between(from: 1.weeks.ago, to: Date.today),
                   message: 'seeding',
                   redirect_uri: ENV['KOALA_DOMAIN']
    )
  end
end