# Sends a mail to members every year (except second and fourth year) requesting updating their study information. If no active studies are filled in consent is requested.
# create a cronjob executing this ones a year; bundle exec rake status:mail
namespace :status do
  desc 'Mail members for updating their status'
  task :mail => :environment do
    # NOTE: all members that joined last year, three years ago, or longer that 5 years ago
    members = Member.studying.where("EXTRACT(YEAR  FROM join_date) in (?) OR EXTRACT(YEAR FROM join_date) <= ?", [Time.current.year - 1, Time.current.year - 3], Time.current.year - 5) +
              Member.alumni.where(consent: [:pending, :yearly]).where("consent_at IS NULL OR consent_at < ?", Date.current)

    if members.empty?
      puts 'No members require an status update'
      next
    end

    Mailings::Status.consent(members.pluck(:id, :first_name, :infix, :last_name, :email)).deliver_later
    puts 'done'
  end

  desc 'Delete all expired tokens'
  task :clean_tokens => :environment do
    Token.clear!
  end
end
