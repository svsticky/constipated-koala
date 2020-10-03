# Managing dependencies

To manage dependencies for this project, [Nix] uses a few tricks.
This includes replacing [Bundler] by [Bundix].
Rails relies on Yarn, so we can't use Nix here.

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
Rails likes to compile its javascript and css dependencies itself:

```console
rails assets:precompile
```
