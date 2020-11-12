{ pkgs ? import ./nix {}
}:
let
  node = import ./nix/node.nix {};
  gems = pkgs.bundlerEnv {
    name = "koala";
    ruby = pkgs.ruby;
    gemdir = ./.;
    gemfile = ./Gemfile;
    lockfile = ./Gemfile.lock;
  };
in
  pkgs.stdenv.mkDerivation {
    name = "koala";
    propagatedBuildInputs = [
      gems
      pkgs.nodejs
      pkgs.ruby
      pkgs.curl
      pkgs.imagemagick
      pkgs.ghostscript
      pkgs.mupdf
      pkgs.cacert
    ];

    buildPhase = ''
      rails assets:precompile
    '';

    installPhase = ''
      mv /build/koala.svsticky.nl $out
    '';

    src = pkgs.nix-gitignore.gitignoreSource [] ./.;

    NODE_PATH = "${(node.shell.override{src = ./dependencies;}).nodeDependencies}/lib/node_modules";

    shellHook = ''
      rails assets:precompile
    '';
  }
