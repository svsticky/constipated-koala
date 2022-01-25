# This tells rails assets:precompile to generate the translations first
task "assets:precompile" => ['i18n:js:export']
