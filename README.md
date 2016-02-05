# Operation Constipated Koala
[![Circle CI](https://circleci.com/gh/StickyUtrecht/constipated-koala/tree/master.svg?style=svg&circle-token=21e53c86a26918537111d53fa15ba2e66f35a851)](https://circleci.com/gh/StickyUtrecht/constipated-koala/tree/master)

This is the repository of the admin system of Study Association Sticky. It has been
written in Ruby with the help of the Rails framework.

Currently, it implements methods to track several things within the association:

 - Members and membership
 - Activities and payments
 - Committees and other groups
 - The Operation Dead Mongoose (TM) and it's expenses

There is more to be implemented :)

## Installing koala
**An extensive tutorial on how to install koala on your laptop or on a production server is [here](config/deployment)**. There are a few *strange* things happening in koala. For one, it is integrated with an [ideal platform](https://github.com/StickyUtrecht/ideal.local). Without proper setting the [.rbenv-vars](.rbenv-vars-sample) it will nog work. Secondly it uses amazon for storing posters and images of mongoose products. In development this should also work on the local machine without amazon's S3 servers. And one regretful thing, posters are uploaded as pdf's, they will be resized and stored in two formats. However the parsing of a pdf file is not working very well and I had to hack in ghostscript a little bit.

Devise and fuzzily are also hacked in a bit. Fuzzily is hacked into to ensure that you can filter first with a `where` and then perform a search on the subset just created. Devise has a feature where an existing member can create a password with their known email address. Both of them are defined in `config/initializers`.

## Contributing
So you want to contribute? Awesome! You are most welcome to. We do however have our
own peculiarities, please try to follow them. It will be much obliged and will smoothen
over the process greatly.

For the admin pages we used a template called [Flatify](http://iarouse.com/dist-flatify/v2.1/index.html#/dashboard) that you should stick to. It is quite extensive and is based on [bootstrap](http://www.getbootstrap.com).

### Branching strategy
The history of this project includes a lot of unnecessary merge commits, which aren't
that pretty. Currently we have a contributing procedure that needs to be followed.

Rest assured it is easy. It is based on one simple rule: **Only @martijncasteel is
allowed to push to `master`.** And he should only do that in case of a merge conflict.

This leaves us with the following workflow:

1. Want to work on something? Create a topic branch.
1. Push the topic branch to GitHub when you want to show something.
1. Open a pull request. Gather feedback. Improve the patch.
1. Occasionally pull from master to ensure you didn't created merge errors.
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
