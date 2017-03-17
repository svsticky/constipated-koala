namespace :devise do

  desc 'Clean users table by removing unconfirmed emails after a set period'
  task :clean_unconfirmed_emails, [:date] => :environment do |t, args|
    args.with_defaults(:date => Time.now - User.confirm_within)
    puts "Clear unconfirmed emails older than #{args[:date]}"

    User.where( 'users.unconfirmed_email IS NOT NULL AND users.confirmation_sent_at < ?', args[:date]).update_all(unconfirmed_email: NIL)
  end
end
