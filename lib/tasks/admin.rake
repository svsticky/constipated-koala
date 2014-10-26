namespace :admin do
  require 'rest_client'

  desc "Finds study progress for all members and updates the DB"
  task studystatus: :environment do
    username = 'blah'
    password = 'blah'
    Open3.popen3("/usr/local/bin/studystatus", "--username", username, "--password", password) {|i, o, e, t|
      i.puts "3947661"
      i.close
      puts o.gets
    }
  end
end
