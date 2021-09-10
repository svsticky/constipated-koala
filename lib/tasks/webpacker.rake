# lib/tasks/webpacker.rake

Rake::Task["webpacker:compile"].clear

namespace :webpacker do
  task :compile do
    Dir.chdir(Rails.root) do
      system({}, "bundle exec ./bin/webpack")

      if ENV['NODE_ENV'] == 'production' || ENV['NODE_ENV'] == 'staging'
        for jspack in ['application', 'doorkeeper', 'public', 'intro', 'members'] do
          system({}, "ln -f ./public$(jq -r '.entrypoints.#{jspack}.js[0]' public/packs/manifest.json) public/packs/js/#{jspack}.js")
        end
        for csspack in ['doorkeeper'] do
          system({}, "ln -f ./public$(jq -r '.entrypoints.#{csspack}.css[0]' public/packs/manifest.json) public/packs/css/#{csspack}.css")
        end
      end
    end
  end
end
