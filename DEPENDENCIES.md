# Managing dependencies

To manage dependencies for this project, [Nix] uses a few tricks.
This includes replacing [Bundler] by [Bundix] and [Yarn] by [yarn2nix].

[Bundler]: https://bundler.io
[Nix]: https://nixos.org/
[Bundix]: https://github.com/nix-community/bundix
[Yarn]: https://yarnpkg.com/
[yarn2nix]: https://github.com/nix-community/yarn2nix
[nixpkgs]: https://search.nixos.org/packages

## System dependencies

Dependencies you'd otherwise install with system package manager can be added to default.nix.
Most packages you'll ever need are found on [nixpkgs].
If this is not the case you'll need to write a derivation yourself.
This is out of scope for this readme.

## Gems (Bundix)

New gems can just be added to the Gemfile.
Updating gems can be done with `bundle update` (be carefull).
After that, run `bundix --lock` to update the gemset.nix file.
A restart of the Nix shell should install the new or updated packages.

## Node / Yarn packages

New node packages should be added to package.json.
After that, run `yarn install` to update the lockfile.
Updating packages can be done with `yarn upgrade`.
To update yarn.nix, run `yarn2nix > yarn.nix`.
