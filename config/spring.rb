%w(
  .ruby-version
  .rbenv-vars
  tmp/restart.txt
).each { |path| Spring.watch(path) }
