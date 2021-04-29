# lib/tasks/webpacker.rake

Rake::Task["webpacker:compile"].clear

namespace :webpacker do
  task :compile do
    Dir.chdir(Rails.root) do
      system({}, "bundle exec ./bin/webpack")
    end
  end
end
