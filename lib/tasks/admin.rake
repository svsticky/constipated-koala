require 'highline'

namespace :admin do
   
  desc "Create a new admin user"
  task :create => :environment do |t, args|
    line = HighLine.new
  
    Admin.create(
      email:                  line.ask('email address'),
      password:               line.ask('password') { |q| q.echo = '*' },
      password_confirmation:  line.ask('confirm password') { |q| q.echo = '*' }
    )
    
    puts 'Admin created!'
  end  
end
