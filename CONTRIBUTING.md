## Contributing

So you want to contribute? Awesome! You are most welcome to. We do however have our
own peculiarities, please try to follow them. It will be much obliged and will smoothen
over the process greatly.

From this point on we are going to use the **[semantic versioning](http://semver.org/)**. This will be the first major release, any fixes increment accordingly `v1.1.9 -> v1.1.10`. Adding functionality in a backwards compatible manner is done like this; `v1.1.10 -> v1.2.0`. And a major release to `v2` is done if there are changes that are not backwards compatible.

### Git hooks

We have some git hooks for checking for missing translations with [I15r](https://github.com/balinterdi/i15r) and running [Rubocop](https://github.com/bbatsov/rubocop).
These hooks are located in the .hooks directory and should activate them by running `git config --local core.hooksPath .hooks`

### New page template

A template for new pages can be found at app/views/layouts/\_blank.html.haml.

### Branching strategy

The history of this project includes a lot of unnecessary merge commits, which aren't
that pretty. Currently we have a contributing procedure that needs to be followed.

Rest assured it is easy. It is based on one simple rule: **Only administrators are
allowed to push to `master`.** And should only do that in case of a merge conflict.

This leaves us with the following workflow:

1. Want to work on something? Create a topic branch.
1. Push the topic branch to GitHub when you want to show something.
1. Open a pull request. Gather feedback. Improve the patch.
1. Occasionally pull from master to ensure you didn't created merge errors.
1. Wait for the PR to be merged into `master`. Then update local history.

Please make sure to write a descriptive commit message. [Here][commit-messages] you
can find some tips for better commit messages.

[commit-messages]: http://robots.thoughtbot.com/5-useful-tips-for-a-better-commit-message

### Branch naming

Try to be descriptive. Use the following prefixes for the names depending on the type
of work:

- `feature/` for new features.
- `bug/` for bugfixes.
- `doc/` for documentation.
- `test/` for testing.
- `debt/` for refactoring and enhancements.

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
