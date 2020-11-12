{ pkgs ? import ./nix {}
}:
let
  node = import ./nix/node.nix {};
  gems = pkgs.bundlerEnv {
    name = "koala";
    ruby = pkgs.ruby;
    gemdir = ./.;
  };
in
  pkgs.stdenv.mkDerivation {
    name = "koala";
    buildInputs = [
      gems
      pkgs.nodejs
      pkgs.ruby
      pkgs.yarn
      pkgs.curl
      pkgs.imagemagick
      pkgs.ghostscript
      pkgs.bundler
      pkgs.mupdf
      pkgs.cacert
    ];

    NODE_PATH = "${node.shell.nodeDependencies}/lib/node_modules";

    shellHook = ''
      rails assets:precompile
    '';
  }
