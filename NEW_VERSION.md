# Creating and tagging a new release

- Create a commit that bumps the version number in `config/application.rb` to
	a [semver]-appropriate higher level, on `development`.
- `git tag` this commit using a command like `git tag v[$YOUR_VERSION]`, like
	`git tag v1.6.3`. You can attach a short changelog to the tag by including
	the output of `git shortlog v[PREVIOUS]..HEAD`.
- Push both the commit and the tag using `git push --follow-tags`. A changelog
	can be added by pasting the output of `git shortlog $(git tag | tail
	-n1)..HEAD`.
- Merge the commit to `master` using either a pull request or the terminal.
	This will always generate a merge commit because of previous merges using
	a merge commit (unless `master` gets merged into `development` again. Ensure no
	actual differences exist between `master` and `development` by checking the
	(empty) output of `git diff master..development` directly after merging.
- Push if not pushed, and deploy if appropriate.

[semver]: https://semver.org
