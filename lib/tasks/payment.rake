namespace :payment do
  desc "sends payment emails"

  task mail: :environment do
    debtors = Member.debtors

    debtors.each do |debtor|
      Mailings::PaymentMailer.requestmail(debtor).deliver_later
    end
  end
end
