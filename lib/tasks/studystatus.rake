namespace :studystatus do
  require 'rest_client'
  require 'open3'

  desc "Update study progress using a stdin in the same format as given by studystatus"
  task :update_from_stdin => :environment do
    STDIN.each do |line|
      member = Member.find_by_student_id(line.split(/; /).first)

      if !member.nil?
        member.update_studies(line)
      else
        puts "#{line.split(/; /).first} is not found in the database"
      end
    end
  end

  desc "Finds study progress for a member and updates the DB"
  task :update, [:username, :password, :student_id] => :environment do |t, args|
    Open3.popen3(ENV['STUDY_SCRIPT'],
                 "--username", args[:username],
                 "--password", args[:password]) do |i, o, e, t|

      member = Member.find_by_student_id(args[:student_id])

      i.puts member.student_id
      member.update_studies(o.gets ||= '')
      i.close
    end
  end

  desc "Finds study progress for all members and updates the DB"
  task :update_all, [:username, :password] => :environment do |t, args|
    # TODO: handle empty username and password
    Open3.popen3(ENV['STUDY_SCRIPT'],
                 "--username", args[:username],
                 "--password", args[:password]) do |i, o, e, t|

      Member.where.not( :student_id => nil ).each do |member|
        i.puts member.student_id
        member.update_studies(o.gets ||= '')
      end

      i.close
    end
  end
end
