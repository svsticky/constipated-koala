namespace :gdpr do
  # Rake task sending members whom require consent, prompts for sending the messages
  # or can be forced by using `bundle exec rake gdpr:mail[y]`.
  desc 'Send consent mail to members'
  task :mail, [:force] => :environment do |_, args|
    members = Member.alumni.where(consent: [:pending, :yearly]).where("consent_at IS NULL OR consent_at < ?", Date.current - 1.year)
    
    if members.empty?
      puts 'No members require a consent mail'
      next
    end

    unless args[:force]&.to_b
      STDOUT.puts "You'll be sending #{ members.size } members an email, continue? (y/n)"
      next unless STDIN.gets.strip.to_b
    end

    # NOTE start sending messages
    Mailings::GDPR.consent(members.pluck(:id, :first_name, :email)).deliver_later
  end

  desc 'Delete all expired tokens'
  task :clean_tokens => :environment do
    Token.clear!
  end
end
