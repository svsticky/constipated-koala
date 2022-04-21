namespace :payment do
  desc "sends payment emails"

  task mail: :environment do
    debtors = Member.debtors

    debtors.each do |debtor|
      puts Mailings::Payment.requestmail(debtor)
    end
  end
end
