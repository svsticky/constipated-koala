namespace :admin do
  require 'rest_client'
  
  desc "Update study progress using a stdin in the same format as given by studystatus"
  task :process => :environment do 
    STDIN.each do |line|
      member = Member.find_by_student_id(line.split(/; /).first)

      if !member.nil?
        member.update_studies(line)
      else
        puts "#{line.split(/; /).first} is not found in the database"
      end
    end
  end  
  
  
  desc "Finds study progress for all members and updates the DB"
  task :studystatus, [:username, :password] => :environment do |t, args|
    # TODO: handle empty username and password
    Open3.popen3("/usr/local/bin/studystatus",
                 "--username", args[:username],
                 "--password", args[:password]) do |i, o, e, t|
      Member.all.each do |member|
        i.puts member.student_id
        output = o.gets
        puts output
        member.update_studies(output)
      end
      i.close
    end
  end
end
