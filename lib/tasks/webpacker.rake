# lib/tasks/webpacker.rake

Rake::Task["webpacker:compile"].clear

namespace :webpacker do
  task :compile do
    Dir.chdir(Rails.root) do
      system({}, "bundle exec ./bin/webpack")

      if ENV['RAILS_ENV'] == 'production' || ENV['RAILS_ENV'] == 'staging'
        %w[application doorkeeper public intro members].each do |jspack|
          system({}, "ln -f ./public$(jq -r '.entrypoints.#{ jspack }.js[0]' public/packs/manifest.json) public/packs/js/#{ jspack }.js")
        end
        ['doorkeeper'].each do |csspack|
          system({}, "ln -f ./public$(jq -r '.entrypoints.#{ csspack }.css[0]' public/packs/manifest.json) public/packs/css/#{ csspack }.css")
        end
      end
    end
  end
end
