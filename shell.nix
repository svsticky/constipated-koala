{ sources ? import ./nix/sources.nix
, pkgs ? import sources.nixpkgs {}
}:
let
  gems = pkgs.bundlerEnv {
    name = "koala";
    ruby = pkgs.ruby_3_0;
    gemdir = ./.;
  };
in
  pkgs.stdenv.mkDerivation {
    name = "koala";
    buildInputs = [
      gems
      pkgs.nodejs
      pkgs.ruby_3_0
      pkgs.yarn
      pkgs.curl
      pkgs.imagemagick
      pkgs.ghostscript
      pkgs.bundler
      pkgs.mupdf
      pkgs.cacert
    ];

    shellHook = ''
      rails assets:precompile
    '';
  }
