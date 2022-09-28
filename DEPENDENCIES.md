# Managing dependencies

To manage dependencies for this project, [Nix] uses a few tricks.
This includes replacing [Bundler] by [Bundix] and [Yarn] by [node2nix]

[Bundler]: https://bundler.io
[Nix]: https://nixos.org/
[Bundix]: https://github.com/nix-community/bundix
[Yarn]: https://yarnpkg.com/
[node2nix]: https://github.com/svanderburg/node2nix
[nixpkgs]: https://search.nixos.org/packages

## System dependencies

Dependencies you'd otherwise install with the system package manager can be added to default.nix.
Most packages you'll ever need are found on [nixpkgs].
If this is not the case you'll need to write a derivation yourself.
This is out of scope for this readme.

## Gems (Bundix)

New gems should be added to the Gemfile.
After that, run `bundix --lock` to update the Gemfile.lock and gemset.nix files.
A restart of the Nix shell should install the new or updated packages.

## Node / Yarn packages

New node packages should be added to package.json.
Be specific about the version you want, node2nix happily updates packages otherwise.
Most of the time you'll want to use the `~` modifier.
After that, run `./bin/node2nix` to update the lockfile.
A restart of the Nix shell should install the new or updated packages.
