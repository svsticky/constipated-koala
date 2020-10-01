{ pkgs ? import <nixpkgs> {} }:
let
  gems = pkgs.bundlerEnv {
    name = "koala";
    ruby = pkgs.ruby_2_5;
    gemdir = ./.;
  };
in
  pkgs.stdenv.mkDerivation {
    name = "koala";
    src = ./.;
    buildInputs = [
        gems
        pkgs.ruby
        pkgs.yarn
        pkgs.nodejs
        pkgs.ruby
        pkgs.yarn
        pkgs.curl
        pkgs.imagemagick
        pkgs.ghostscript
        pkgs.bundler];
    installPhase = ''
      cp -r $src $out
    '';
  }
