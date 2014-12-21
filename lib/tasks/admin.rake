namespace :admin do
  
  desc "Create a new admin user"
  task :create, [:email, :password] => :environment do |t, args|o 
    admin = Admin.create(
      email:                  args[:email],
      password:               args[:password],
      password_confirmation:  args[:password]
    )
    
    puts "#{admin.credentials.email} created!"
  end  
end