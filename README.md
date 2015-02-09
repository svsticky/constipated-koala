# Operation Constipated Koala

This is the repository of the admin system of Study Association Sticky. It has been
written in Ruby with the help of the Rails framework.

Currently, it implements methods to track several things within the association:

 - Members and membership
 - Activities and payments
 - The Operation Dead Mongoose (TM) and it's expenses

There is more to be implemented :)

## Development setup

You will need a working package manager, and a working ruby version manager and/or
build tools.

### External dependencies

Install before continuing:

 - `ruby-2.1.2` (install with [`rbenv install`][rbenv] or, if you must, [`rvm`][rvm]);
 - MySQL with database created.

  [rbenv]: https://github.com/sstephenson/rbenv
  [rvm]: http://rvm.io/

We use MySQL (or a compatible) both in development and production. This to minimalize
development/production mismatches. No SQLite here.

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

### A note on databases

There used to be a section here telling you to be a bit fearful of running the
`db:migrate` rake task. This was misinformed. For more information on this historical
perspective you can check out issue 53.

Here are the rake tasks that you will need to use in order to effectively contribute
to this project:

 - When starting out, `rake db:create` will set you up with a nice development
   database. It won't, however fill it with any tables.
 - To create the relevant tables and seed them you can use `rake db:setup`.
 - When there are pending migrations (database changes), `rake db:migrate` will do
   the job nicely. Use this when you create migrations yourself or when the
   `rake db:setup` task fails due to pending migrations (in this latter case notify
   the maintainer and complain about bad code review).
 - Messed something up? Run the task `db:reset`. This will drop the database, create
   it and set it back up again.

`schema.rb` is a file that describes the database schema of this application. Any
changes to it are critical, therefore it is paramount that you check this file into
version control.

## Contributing

So you want to contribute? Awesome! You are most welcome to. We do however have our
own pecularities, please try to follow them. It will be much obliged and will smoothen
over the process greatly.

### Branching strategy

The history of this project includes a lot of unnecessary merge commits, which aren't
that pretty. Currently we have a contributing procedure that needs to be followed.

Rest assured it is easy. It is based on one simple rule: **Only @martijncasteel is
allowed to push to `master`.** And he should only do that in case of a merge conflict.

This leaves us with the following workflow:

1. Want to work on something? Create a topic branch.
1. Push the topic branch to GitHub when you want to show something.
1. Open a pull request. Gather feedback. Improve the patch.
1. Wait for the PR to be merged into `master`. Then update local history.

Please make sure to write a descriptive commit message. [Here][commit-messages] you
can find some tips for better commit messages.

 [commit-messages]:http://robots.thoughtbot.com/5-useful-tips-for-a-better-commit-message

### Example contributing flow

```bash
# Create and checkout a new branch for the contribution
$ git checkout -b doc/contributing-guidelines
# Make your changes
$ vim README.md
# Commit changes
$ git add . && git commit -m "Draft contributing guidelines"
# Push the branch to GitHub
$ git push origin doc/contributing-guidelines
```

Now open a pull request and wait for feedback. If you need to make any more changes,
simply create new commits and push these to GitHub.

When the feature is merged by @martijncasteel, you can get the changes by pulling
from GitHub.

```bash
# Make sure we're on master
$ git checkout master
# Get the changes from GitHub, this should NEVER, EVER introduce a merge conflict
$ git pull origin master
```

### Branch naming

Try to be descriptive. Use the following prefixes for the names depending on the type
of work:

 - `feature/` for new features.
 - `bug/` for bugfixes.
 - `doc/` for documentation.
 - `test/` for testing.
 - `debt/` for refactoring and enhancements.

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
