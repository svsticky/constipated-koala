namespace :studystatus do
  desc 'Mail members for updating studystatus'
  task :mail, [:force] => :environment do |_, args|
    # NOTE all members die joined last year, three years ago, or longer that 5 years ago
    members = Member.studying.where("YEAR(join_date) in (?) OR YEAR(join_date) < ?", [Time.current.year - 1, Time.current.year - 3], Time.current.year - 5)

    if members.empty?
      puts 'No members require an studystatus update'
      next
    end

    unless args[:force]&.to_b
      STDOUT.puts "You'll be sending #{ members.size } members an email, continue? (y/n)"
      next unless STDIN.gets.strip.to_b
    end

    # TODO: members.pluck(:id, :first_name, :email) + studies
    # logica, eerst bachelor, als die klaar is master. Meerdere bachelors mogelijk
    Mailings::Studystatus.consent({}).deliver_later
  end

  desc 'Delete all expired tokens'
  task :clean_tokens => :environment do
    Token.clear!
  end
end
