namespace :admin do
  desc 'Create a new admin user'
  task :create, [:email, :password] => :environment do |t, args|
    admin = Admin.new(
      email:                  args[:email],
      password:               args[:password],
      password_confirmation:  args[:password]
    )

    if admin.save!
      puts "#{args[:email]} created!"
    else
      puts 'admin not created, does the password meet the requirements?'
    end
  end

  desc 'Delete a normal user, that is it\'s login access'
  task :remove, [:email] => :environment do |t, args|
    user = User.find_by_email args[:email]

    if user.nil?
      puts "#{args[:email]} not found"
      exit
    elsif user.admin?
      puts "#{args[:email]} is an admin account and its login access can not be removed"
      exit
    end

    puts "#{args[:email]} removed" if user.destroy
  end

  desc 'Delete an admin account and user'
  task :delete, [:email] => :environment do |t, args|
    user = User.find_by_email args[:email]

    if user.nil? || !user.admin?
      puts "#{args[:email]} not found"
      exit
    end

    puts "#{args[:email]} removed" if user.credentials.destroy
  end

  desc 'Reindex fuzzily for all members'
  task :reindex_members => :environment do |t|
    puts 'reindex members..'
    Member.bulk_update_fuzzy_query
    puts 'reindex done!'
  end

  desc 'Start a new year, create a new membership activity if given and set in config'
  task :start_year, [:membership, :price] => :environment do |t, args|
    # remove activities from settings if passed
    Activity.find( Settings['intro.activities'] ).each do |activity|
      next unless activity.start_date < Date.today
      Settings['intro.activities'] -= [activity.id]
    end

    exit unless Settings.begin_study_year <= Date.today

    # create new activity if it is time
    activity = Activity.create(
      name:                 args[:membership] ||= 'Lidmaatschap',
      price:                args[:price] ||= 7.5,
      start_date:           Settings.begin_study_year,
      description:          'automatisch gegenereerde activiteit'
    )

    # set next date for new activity
    Settings.begin_study_year = Date.today + 1.year
    Settings['intro.membership'] = [activity.id]
  end
end
