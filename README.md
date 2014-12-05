# Operation Constipated Koala

## Dev setup

You will need a working package manager, and a working ruby version manager and/or
build tools.

### External dependencies

Install before continuing:

 - `ruby-2.1.2` (install with [`rbenv install`][rbenv] or, if you must, [`rvm`][rvm]);
 - MySQL with database created.

  [rbenv]: https://github.com/sstephenson/rbenv
  [rvm]: http://rvm.io/

### Running the Rails app

This is how you can get started with the development setup.

```shell
# Clone and switch directories:
$ git clone git@github.com:StickyUtrecht/ConstipatedKoala.git && cd ConstipatedKoala

# Install ruby dependencies:
$ bundle install

# Create `config/database.yml` with adapter `mysql2` and database credentials
$ mvim config/database.yml

# Create and populate the database
$ bundle exec rake db:create && bundle exec rake db:setup

# Run the server
$ bundle exec rails server

# Add dev host to hosts file
$ echo "127.0.0.1 koala.rails.dev intro.rails.dev" >> /etc/hosts
```

All done! Now you have the admin system and intro website running at:

 - [`http://koala.rails.dev:3000`](http://koala.rails.dev:3000)
 - [`http://intro.rails.dev:3000`](http://intro.rails.dev:3000)

### A note on `rake db:migrate` tasks

Do **NOT** run `rake db:migrate` *unless* you changed something to the schema. The
schema is stored in `db/schema.rb`. `using rake db:migrate` will give this file a
timestamp update, which is annoying.

Here is a brief manual for running `rake` tasks in the `db` namespace:

 - **Only run `bundle exec rake db:migrate` when you have created a migration. Do NOT
   use this command when setting up your database.**
 - Wanting to set up your dev-env? First create a database with `bundle exec rake
   db:create`. Then use `bundle exec rake db:setup`. (This will run the subtasks
   `db:schema:load` and `db:seed`.)
 - Messed something up? Run the task `db:reset`. (Which is an alias for `db:drop`
   followed by `db:setup`.)

If you want to learn more, see issue #53.

## Contributing

For new features, create a new branch starting with `feature/` in this way the
features will be grouped. After developing and testing the feature locally request a
pull request and the feature will be merged with the master branch.

## License

```
ConstipatedKoala is licensed under the GPLv3 license.

Copyright (C) 2014 Tako Marks, Martijn Casteel, Laurens Duijvesteijn

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
```
