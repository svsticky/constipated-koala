namespace :devise do

  desc 'Clean users table by removing unconfirmed emails after a set period'
  task :clean_unconfirmed_emails => :environment do
    puts 'clear unconfirmed emails'

    User.where( 'users.unconfirmed_email IS NOT NULL AND users.confirmation_sent_at < ?', Time.now - User.confirm_within ).update_all({ :unconfirmed_email => NIL, :confirmation_sent_at => NIL })
  end

  desc 'Clean users table by removing unconfirmed emails after a set period'
  task :clean_reset_tokens => :environment do
    puts 'clear reset tokens'

    User.where( 'users.reset_password_token IS NOT NULL AND users.reset_password_sent_at < ?', Time.now - User.reset_password_within ).update_all({ :reset_password_token => NIL, :reset_password_sent_at => NIL })
  end
end
