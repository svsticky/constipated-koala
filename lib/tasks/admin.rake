namespace :admin do
  
  desc "Create a new admin user"
  task :create, [:email, :password] => :environment do |t, args|
    Admin.create(
      email:                  args[:email],
      password:               args[:password],
      password_confirmation:  args[:password]
    )
    
    puts "#{args[:email]} created!"
  end  
end
