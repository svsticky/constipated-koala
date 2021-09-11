# lib/tasks/webpacker.rake

Rake::Task["webpacker:compile"].clear

namespace :webpacker do
  task :compile do
    Dir.chdir(Rails.root) do
      system({}, "bundle exec ./bin/webpack")

      # Here follows a weird trick that really speeds up the application.
      # 'Normally', packs are served by Webpacker, a gem that is fast enough for development,
      # and very convenient when assets are changing. For production it is slow and just overkill however.
      # To circumvent Webpacker, we precompile the assets, and then symlink each pack to a default location.
      # We have to create symlinks because Webpacker likes to add a hash to each pack.
      # We get the right location to symlink from the manifest (also created by Webpacker).
      # This is done with `jq`, a command line json processing tool.
      # Each view that needs packs has a comparable RAILS_ENV check, and depending on the environment serves
      # the packs via Webpacker or directly
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
