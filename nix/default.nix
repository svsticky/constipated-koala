let sources = import ./sources.nix;
in {
  nixpkgs = import sources.nixpkgs;
  gitignore = import sources.gitignore;
}
