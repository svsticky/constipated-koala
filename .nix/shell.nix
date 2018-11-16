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
    buildInputs = [gems pkgs.ruby_2_5 pkgs.yarn pkgs.nodejs-10_x];
    installPhase = ''
      cp -r $src $out
    '';
  }
