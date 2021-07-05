%w[
  .ruby-version
  .env
  tmp/restart.txt
  tmp/caching-dev.txt
].each { |path| Spring.watch(path) }
