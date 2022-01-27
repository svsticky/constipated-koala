# set path to application
app_dir = File.expand_path('..', __dir__)
working_directory app_dir

# Set unicorn options
worker_processes ENV.fetch('RAILS_MAX_THREADS', 4).to_i
preload_app true
timeout 30

# Set up socket location
listen "/tmp/unicorn.sock", backlog: 64

# Logging
stderr_path "#{ app_dir }/log/unicorn.log"
stdout_path "#{ app_dir }/log/unicorn.log"

# Set master PID location
pid "#{ app_dir }/tmp/pids/unicorn.pid"

# Garbage collection settings.
GC.respond_to?(:copy_on_write_friendly=) &&
  GC.copy_on_write_friendly = true

# If using ActiveRecord, disconnect (from the database) before forking.
before_fork do |_server, _worker|
  defined?(ApplicationRecord) &&
    ApplicationRecord.connection.disconnect!
end

# After forking, restore your ActiveRecord connection.
after_fork do |_server, _worker|
  defined?(ApplicationRecord) &&
    ApplicationRecord.establish_connection
end
