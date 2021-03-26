{ sources ? import ./nix
}:
let
  pkgs = sources.nixpkgs {};
  gitignore = sources.gitignore{ lib = pkgs.lib; };
  node = import ./nix/node.nix {};
  gems = pkgs.bundlerEnv {
    name = "koala";
    ruby = pkgs.ruby;
    gemdir = ./.;
    gemfile = ./Gemfile;
    lockfile = ./Gemfile.lock;
    gemConfig = pkgs.defaultGemConfig // {
      mimemagic = attrs: {
        FREEDESKTOP_MIME_TYPES_PATH = "${pkgs.shared-mime-info}/share/mime/packages/freedesktop.org.xml";
      };
    };
  };
  node-path = "${(node.shell.override{src = node-jail;}).nodeDependencies}/lib/node_modules";
  node-jail = import ./nix/node-jail.nix {};
in
  pkgs.stdenv.mkDerivation {
    name = "koala";
    propagatedBuildInputs = [
      pkgs.shared-mime-info
      gems
      pkgs.nodejs
      pkgs.ruby
      pkgs.curl
      pkgs.imagemagick
      pkgs.ghostscript
      pkgs.mupdf
      pkgs.cacert
      pkgs.bundler
    ];


    buildPhase = ''
      rails assets:precompile
    '';

    koala_rails_wrapper = pkgs.writeScript "koala" ''
      #!/bin/bash
      export NODE_PATH=${node-path}
      ${gems.wrappedRuby}/bin/bundle exec rails $@
    '';

    installPhase = ''
      ln -s $koala_rails_wrapper /build/constipated-koala/bin/koala
      mv /build/constipated-koala $out
    '';

    #src = pkgs.nix-gitignore.gitignoreSource [] ./.;

    src = builtins.path {
      name = "constipated-koala";
      path = ./.;
      filter = gitignore.gitignoreFilter ./.;
    };

    NODE_PATH = node-path;

    shellHook = ''
      dotenv rails assets:precompile
    '';

    LC_ALL = "C.UTF-8";
  }
