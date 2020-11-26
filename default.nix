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
  node-path = "${(node.shell.override{src = node-jail;}).nodeDependencies}/lib/node_modules";
  node-jail = import ./nix/node-jail.nix {};
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
      pkgs.bundler
      (pkgs.writeTextFile {
        name = "koala-rails";
        text = ''
          #!/bin/bash
          export NODE_PATH="${node-path}"
          rails $@
        '';
        executable=true;
      })
    ];

    buildPhase = ''
      rails assets:precompile
    '';

    installPhase = ''
      mv /build/koala.svsticky.nl $out
    '';

    src = pkgs.nix-gitignore.gitignoreSource [] ./.;

    NODE_PATH = node-path;

    shellHook = ''
      rails assets:precompile
    '';

    LC_ALL = "C.UTF-8";

    BUNDLER_IGNORE_CONFIG = "True";
  }
