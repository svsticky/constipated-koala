require Rails.root.join('db', 'seeds', 'members.rb')
require Rails.root.join('db', 'seeds', 'activities.rb')

puts '-- member transaction creation'
Member.all.sample(30).each do |member|

  5.times do
    transactiontype = Faker::Number.within(range: 0..1)
    paymenttype = Faker::Number.within(range:0..3)
    status = paymenttype == 0 ? ["PAID", "EXPIRED", "Cancelled"].sample : ["SUCCEEDED", "FAILED", "EXPIRED"].sample
    if transactiontype == 1 && status == "SUCCEEDED"
      participants = Participant.where(member:member).where.not(activity:nil).select{|p| p.currency != nil}.sample(Faker::Number.within(range:1..6))
      participants.map {|p|p.update(paid:true)}
      transaction_id = participants.map{|p| p.activity.id}
      amount = 0
      participants.map{ |p| amount += p.currency}
    else
      transaction_id = [1]
    end
    description = transactiontype == 0 ? "Mongoose Opwaardering" : "Activiteiten - #{transaction_id}"
    Payment.create(member: member,
                   transaction_type: transactiontype,
                   payment_type: paymenttype ,
                   transaction_id: transaction_id,
                   description: description,
                   amount: Faker::Number.within(range: 1.0..10.0),
                   status: status,
                   trxid: Digest::MD5.hexdigest(status + description + Time.now.to_f.to_s)
    ).save
  end
end