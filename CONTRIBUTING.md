# Contributing

So you want to contribute? Awesome! You are most welcome to. We do however have our
own peculiarities, please try to follow them. It will be much obliged and will smoothen
over the process greatly.

## Versioning

We use **[semantic versioning](http://semver.org/)**.
Bugfixes increment the version like this: `v1.1.9 -> v1.1.10`.
Adding functionality in a backwards compatible manner is done like this; `v1.1.10 -> v1.2.0`.
Major releases are done if there are changes that are not backwards compatible.

### Git hooks

We have some git hooks for checking for missing translations with [I15r](https://github.com/balinterdi/i15r) and running [Rubocop](https://github.com/bbatsov/rubocop).
These hooks are located in the .hooks directory and should activate them by running `git config --local core.hooksPath .hooks`

### New page template

A template for new pages can be found at app/views/layouts/\_blank.html.haml.

### Translations

When working on the application you might find or introduce some new text.
If this is the case, please replace or put the translation in the correct translation files.
To help you with this, we are using the [i18n-tasks](https://github.com/glebm/i18n-tasks) gem.
Run the `i18n-tasks health` command to check whether something is wrong with the translations or to see if you forgot to add a translation.
For other commands please check out their [Home page](https://glebm.github.io/i18n-tasks/).

### Branching strategy

The history of this project includes a lot of unnecessary merge commits, which aren't
that pretty. Currently we have a contributing procedure that needs to be followed.

Rest assured it is easy. It is based on one simple rule: **Only administrators are
allowed to push to `master`.** And should only do that in case of a merge conflict.

This leaves us with the following workflow:

1. Want to work on something? Create a topic branch.
1. Push the topic branch to GitHub when you want to show something.
1. Open a pull request. Gather feedback. Improve the patch.
1. Occasionally pull from `development` to ensure you didn't created merge errors.
1. Wait for the PR to be merged into `development`. Then update local history.

Please make sure to write a descriptive commit message. [Here][commit-messages] you
can find some tips for better commit messages.

[commit-messages]: http://robots.thoughtbot.com/5-useful-tips-for-a-better-commit-message

### Branch naming

Try to be descriptive.
Use the following prefixes for the names depending on the type
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
