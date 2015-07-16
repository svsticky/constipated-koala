# set path to application
app_dir = File.expand_path("../..", __FILE__)
working_directory app_dir


# Set unicorn options
worker_processes 2
preload_app true
timeout 30

# Set up socket location
listen "/tmp/unicorn.sock", :backlog => 64

# Logging
stderr_path "#{app_dir}/log/unicorn.log"
stdout_path "#{app_dir}/log/unicorn.log"

# Set master PID location
pid "#{app_dir}/tmp/pids/unicorn.pid"
