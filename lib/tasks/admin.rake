namespace :admin do
  
  desc "Create a new admin user"
  task :create, [:email, :password] => :environment do |t, args|
    admin = Admin.create(
      email:                  args[:email],
      password:               args[:password],
      password_confirmation:  args[:password]
    )
    
    User.create(
      email:                  args[:email],
      password:               args[:password],
      password_confirmation:  args[:password],
      
      credentials:            admin
    )
    
    puts "#{args[:email]} created!"
  end  
end
