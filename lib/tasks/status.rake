namespace :status do
  desc 'Mail members for updating studystatus'
  task :mail, [:force] => :environment do
    # NOTE all members die joined last year, three years ago, or longer that 5 years ago
    members = Member.studying.where("YEAR(join_date) in (?) OR YEAR(join_date) < ?", [Time.current.year - 1, Time.current.year - 3], Time.current.year - 5) +
              Member.alumni.where(consent: [:pending, :yearly]).where("consent_at IS NULL OR consent_at < ?", Date.current - 1.year)

    if members.empty?
      puts 'No members require an status update'
      next
    end

    # TODO: members.pluck(:id, :first_name, :email) + studies
    # logica, eerst bachelor, als die klaar is master. Meerdere bachelors mogelijk
    Mailings::Status.consent({}).deliver_later
  end

  desc 'Delete all expired tokens'
  task :clean_tokens => :environment do
    Token.clear!
  end
end
